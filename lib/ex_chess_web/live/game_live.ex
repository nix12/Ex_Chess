defmodule ExChessWeb.GameLive do
  @moduledoc """
  Shows active game.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.{Repo, Core}
  alias ExChess.Accounts.User

  def mount(%{"game_id" => game_id}, _session, socket) do
    socket = 
      if connected?(socket) do
        current_user = socket.assigns.current_user

        tracking_params = %{
          id: current_user.email,
          username: current_user.username, 
          status: current_user.status
        }
        
        ExChessWeb.Presence.track_user(game_id, current_user.email, tracking_params)
        ExChessWeb.Presence.subscribe(game_id)
        
        game = 
          game_id
          |> Core.new_game()
          |> Core.add_player(current_user)
          |> Core.find_opponent(current_user)          

        meta = meta(game)

        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users(game_id))
        |> assign(page: "show_game")
        |> assign(game_id: game_id)
        |> assign(game: game) 
        |> assign(board: game.board)
        |> assign(meta: meta)
        |> assign(color: get_color_from_meta(current_user, meta))
      else
        socket
        |> stream(:presences, [])
        |> assign(page: "loading")
      end

      {:ok, socket}
  end

  def render(%{page: "show_game"} = assigns) do
    ~H"""
    <div>
      <.live_component
        module={ExChessWeb.Board}
        id={@game_id} 
        display={display(@board)} 
        game_id={@game_id}
        game={@game}
        current_user={@current_user}
        board={@board}
        meta={@meta}
      />

      <div>
        <h4>Current User</h4>

        <span>
          <%= @current_user.username %> (<%= @color %>)
        </span>
      </div>

      <div>
        <h4>Online User</h4>

        <ul id="online_users" phx-update="stream">
          <li 
            :for={{dom_id, %{metas: metas}} <- @streams.presences} 
            id={dom_id}not
          >
            <%= metas |> Enum.at(0) |> Map.get(:username) %>
          </li>     
        </ul>
      </div>
    </div>
    """
  end
  
  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading</h1>
    """
  end

  def handle_info({"update_game", game}, socket) do
    IO.puts("===GAME===")
    
    {:ok, assign(socket, game: game)}
  end
  
  def handle_info({ExChessWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({ExChessWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  @doc """
  Broadcast movement of positions to all connected users.
  """
  def handle_info({"broadcast_move", updated_board}, socket) do     
    Core.save_game(socket.assigns.game, updated_board)

    PubSub.broadcast!(
      ExChess.PubSub,
      "game:" <> socket.assigns.game_id,
      {"update_board", updated_board}
    )

    {:noreply, socket}
  end

  @doc """
  Handles the update of the current state of chessboard
  """
  def handle_info({"update_board", updated_board}, socket) do
    IO.puts("===UPDATE ALL===")
    
    {:noreply, assign(socket, board: updated_board)}
  end

  defp display(board) do
    board |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end

  defp meta(game) do
    player = game.player
    opponent = game.opponent
    player_color = color()

    %{
      player: %{user: %{user_data: player, color: player_color}}, 
      opponent: %{user: %{user_data: opponent, color: opponent_color(player_color)}}
    }
  end

  def color() do
    if :rand.uniform(100) < 50, do: :white, else: :black   
  end

  def opponent_color(player_color) do
    case player_color do
      :white ->
        :black 
    
      :black ->
        :white
    end
  end  

  def get_color_from_meta(current_user,  meta) do
    case current_user.id do
      id when id == meta.player.user.user_data.id ->
        meta.player.user.color

      id when id == meta.opponent.user.user_data.id ->
        meta.opponent.user.color
    end
  end
end
