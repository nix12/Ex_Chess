defmodule ExChessWeb.BoardLive.Show do
  use ExChessWeb, :live_view

  alias ExChess.Core
  alias ExChess.Core.Pieces.Rook

  def mount(_params, _session, socket) do
    id = ExChess.random_string()
    Core.create_board(id)

    socket =
      socket
      |> assign(:board_id, id)
      |> assign(:board, Core.build_board(id))

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={ExChessWeb.Boards} id={@board_id} board={@board} />
    """
  end

  def handle_event("click", _unsigned_params, socket) do
    board = Core.set_board(socket.assigns.board_id)

    # board = ExChess.Core.Boards.Board.count(socket.assigns.board_id)

    # board = Core.print_board(socket.assigns.board_id)
    socket = assign(socket, :board, board)

    {:noreply, socket}
  end
end
