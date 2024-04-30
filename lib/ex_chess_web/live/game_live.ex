defmodule ExChessWeb.GameLive.Show do
  @moduledoc"""
  Chess board live view.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.Core

  def mount(_params, _session, socket) do
  if connected?(socket) do
      current_user = socket.assigns[:current_user]
      game_id = "asdf" # generate_game_id()

      ExChessWeb.Presence.track_user(game_id, current_user.email, %{id: current_user.email})
      ExChessWeb.Presence.subscribe(game_id)
      
      socket =
        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users(game_id))
        |> assign(page: "show_game")
        |> assign(game_id: game_id)
        |> assign(board: Core.build_board())
        |> assign(game: Core.new_game())

      {:ok, socket}

    else
      socket =
        socket
        |> stream(:presences, [])
        |> assign(page: "loading", game_id: nil)

      {:ok, socket}
    end
  end

  def render(%{page: "show_game"} = assigns) do
    ~H"""
    <div>
      <ExChessWeb.Board.chessboard
        id={@game_id} 
        display={display(@board)} 
        game={@game}
        board={@board}
      />

      <div>
        <h4>Current User</h4>
        <span>
          <%= @current_user.email %>
        </span>
      </div>
      <div><h4>Online User</h4></div>
      <ul id="online_users" phx-update="stream">
        <li :for={{dom_id, %{id: id, metas: metas}} <- @streams.presences} id={dom_id}><%= id %> (<%= length(metas) %>)</li>
      </ul>
    </div>
    """
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading</h1>
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
    PubSub.broadcast!(
      ExChess.PubSub,
      "game:" <> socket.assigns[:game_id],
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

  defp generate_game_id() do
    length = 12

    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp display(board) do
    board |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end
end
