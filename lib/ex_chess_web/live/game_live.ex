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
      # generate_game_id()
      game_id = "asdf"

      # ExChessWeb.Presence.track_user(params["name"], %{id: params["name"]})
      ExChessWeb.Presence.track_user(current_user.email, %{id: current_user.email})
      ExChessWeb.Presence.subscribe()
      
      socket =
        socket
        # |> stream(:presences, [])
        |> assign(page: "show_game")
        |> assign(game_id: game_id)
        |> assign(game: Core.new_game(game_id, Core.build_board()))
        |> stream(:presences, ExChessWeb.Presence.list_online_users())

      {:ok, socket}

    else
      {:ok, assign(socket, page: "loading", game_id: nil)}
    end
  end

  def render(%{page: "show_game"} = assigns) do
    ~H"""
    <div>
      <.live_component 
        module={ExChessWeb.Board} 
        id={@game_id} 
        display={display(@game)} 
        game={@game}
      />

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
    PubSub.broadcast(
      ExChess.PubSub,
      "game:" <> socket.assigns[:game_id],
      {"update_board", updated_board}
    )

    {:noreply, socket}
  end

  @doc """
  Handles the update of the current state of chess board
  """
  def handle_info({"update_board", updated_board}, socket) do
    IO.puts("===BROADCAST===")
    {:noreply, assign(socket, %{game: %{board: updated_board}})}
  end

  defp generate_game_id() do
    length = 12

    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end

  defp display(game) do
    game.board |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end
end
