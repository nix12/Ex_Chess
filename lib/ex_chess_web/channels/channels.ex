defmodule ExChessWeb.MyChannel do
  use ExChessWeb, :channel
  alias ExChessWeb.Presence

  def join("board:" <> board_id, %{"board_id" => [board_id | _rest]}, socket) do
    send(self(), :after_join)
    {:ok, assign(socket, :user_id, ExChess.random_string())}
  end

  def handle_info(:after_join, socket) do
    {:ok, _} =
      Presence.track(socket, socket.assigns.user_id, %{
        online_at: inspect(System.system_time(:second))
      })

    push(socket, "presence_state", Presence.list(socket))
    {:noreply, socket}
  end
end
