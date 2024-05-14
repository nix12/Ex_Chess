defmodule ExChessWeb.GameLive do
  @moduledoc """
  Shows active game.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.Core

  def mount(%{"game_id" => game_id}, _session, socket) do
    socket = 
      if connected?(socket) do
        current_user = socket.assigns.current_user

        tracking_params = %{
          id: current_user.email,
          username: current_user.username, 
          status: current_user.status
        }
        
        ExChessWeb.Presence.track_user("G-" <> game_id, current_user.email, tracking_params)
        ExChessWeb.Presence.subscribe(game_id)
        
        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users("G-" <> game_id))
        |> assign(page: "show_game")
        |> assign(game_id: game_id)
        |> assign(game: Core.new_game(game_id, current_user)) 
        |> assign(board: Core.build_board())
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
      />

      <div>
        <h4>Current User</h4>

        <span>
          <%= @current_user.username %>
        </span>
      </div>

      <div>
        <h4>Online User</h4>

        <ul id="online_users" phx-update="stream">
          <li 
            :for={{dom_id, %{metas: metas}} <- @streams.presences} 
            id={dom_id}
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
    IO.puts("UPDATE GAME")
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
end
