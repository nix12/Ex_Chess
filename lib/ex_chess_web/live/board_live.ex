defmodule ExChessWeb.BoardLive.Show do
  use ExChessWeb, :live_view

  alias ExChess.Core

  def mount(_params, _session, socket) do
    id = ExChess.random_string()
    Core.create_board(id)

    sorted_board =
      Core.set_board(id) |> Enum.sort_by(fn {location, _} -> location end) |> Enum.reverse()

    socket =
      socket
      |> assign(:board_id, id)
      |> assign(:board, sorted_board)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={ExChessWeb.Boards} id={"#{@board_id}"} board={@board} />
    """
  end
end
