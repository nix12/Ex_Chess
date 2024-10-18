defmodule ExChessWeb.GameLive do
  @moduledoc"""
  Shows active game.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.Core
  alias ExChess.Core.Schema.Game

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

        {:ok, game} = Core.new_game(game_id, current_user) 
         
        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users(game_id))
        |> assign(game_id: game_id)
        |> assign(game: game) 
        |> assign(color: color(game, current_user))
        |> assign(board: board(game))
        |> assign(page: "game")
      else
        socket
        |> stream(:presences, [])
        |> assign(page: "loading")
      end

    {:ok, socket}
  end

  def render(%{page: "game"} = assigns) do
    ~H"""
    <div>
      <.live_component
        module={ExChessWeb.Chessboard}
        id={@game_id} 
        current_user={@current_user}
        display={display(@board)} 
        game={@game}
        board={@board}
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
    <h1>Loading...</h1>
    """
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
    update_game = %Game{socket.assigns.game | chessboard: %{socket.assigns.game.chessboard | board: updated_board}} 

    PubSub.broadcast!(ExChess.PubSub, "game:" <> socket.assigns.game_id, {"update_game", update_game})

    {:noreply, socket}
  end

  def handle_info({"update_game", updated_game}, socket) do
    # Core.save_game(updated_game)

    {:noreply, assign(socket, board: updated_game.board, game: updated_game)}
  end

  defp display(board) do
    Enum.sort_by(board, fn {location, _} -> location end, :desc)
  end 

  defp get_color_from_participants(participants, current_user) do
    case current_user.id do
      id when id == participants.player_id ->
        participants.player_color

      id when id == participants.opponent_id ->
        participants.opponent_color
    end
  end

  defp color(game, current_user) do
    game 
    |> Map.get(:participants)
    |> get_color_from_participants(current_user)
  end

  defp board(game) do
    game
    |> Map.get(:chessboard)
    |> Map.get(:board)
  end
end
