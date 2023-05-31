defmodule ExChessWeb.BoardLive.Show do
  use ExChessWeb, :live_view

  alias ExChess.Core
  alias Phoenix.PubSub

  def mount(%{"board_id" => [board_id | _empty]}, session, socket) do
    found_board = Registry.lookup(ExChessGameRegistry, board_id)

    if found_board == [] do
      {:ok, pid} = Core.create_board(board_id)
      PubSub.subscribe(ExChess.PubSub, "board:" <> board_id)
    else
      PubSub.subscribe(ExChess.PubSub, "board:" <> board_id)
    end

    sorted_board =
      Core.set_board(board_id) |> Enum.sort_by(fn {location, _} -> location end) |> Enum.reverse()

    socket =
      socket
      |> assign(:board_id, board_id)
      |> assign(:board, sorted_board)

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.live_component module={ExChessWeb.Boards} id={@board_id} board={@board} />
    """
  end

  def handle_info({"movement", params}, socket) do
    {:noreply, push_event(socket, "updated", params)}
  end
end
