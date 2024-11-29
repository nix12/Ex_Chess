defmodule ExChessWeb.LobbyLive do
  @moduledoc """
  Handles initial connection to application
  """
  require FriendlyID

  use ExChessWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        IO.puts("LOBBY CONNECTED")
        current_user = socket.assigns[:current_user]

        ExChessWeb.Presence.subscribe(current_user.id)

        socket
      else
        socket
      end

    {:ok, socket}
  end

  @impl true
  def handle_info({"navigate", %{game_id: game_id, opponent_id: opponent_id}}, socket) do
    socket =
      if socket.assigns.current_user.id == opponent_id do
        redirect(socket, to: ~p"/game/#{game_id}")
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("dummy", params, socket) do
    IO.puts("LOBBBY DUMMY")
    IO.inspect(params, label: "PARAMS")
    {:noreply, socket}
  end
end
