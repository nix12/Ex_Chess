defmodule ExChessWeb.BoardLive.Show do
  @moduledoc"""
  Chess board live view.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.Core

  def mount(%{"board_id" => [board_id]}, _session, socket) do
    case connected?(socket) do
      true ->
        PubSub.subscribe(ExChess.PubSub, "board:" <> board_id)
        
        socket =
          socket
          |> assign(:page, "show_game")
          |> assign(:board_id, board_id)
          |> assign(:board, start_game(board_id))

        {:ok, socket}

      false ->
        {:ok, assign(socket, page: "loading", board_id: nil)}
    end
  end

  def render(%{page: "show_game"} = assigns) do
    ~H"""
    <.live_component module={ExChessWeb.Boards} id={@board_id} board={@board} />
    """
  end

  def render(%{page: "loading"} = assigns) do
    ~H"""
    <h1>Loading</h1>
    """
  end

  @doc"""
  Displays updated board after chess piece movement on connected devices.
  """
  def handle_info({"movement", params, updated_board}, socket) do
    display = updated_board |> Enum.sort_by(fn {location, _} -> location end, :desc)
    socket = assign(socket, :board, display)
    [{pid, _}] = Registry.lookup(ExChessGameRegistry, socket.assigns.board_id)

    send(pid, {"update_board", updated_board})
    {:noreply, socket}
  end

  @doc"""
  Upon mount, check if current board is found. If found
  create new board. Else, get current state of the chess board.
  Then sort board for display.
  Raise if board not connected to socket.
  """
  defp start_game(board_id) do
    found_board = Registry.lookup(ExChessGameRegistry, board_id)

    cond do
      found_board == [] ->
        with {:ok, _pid} <- Core.create_board(board_id),
              _ <- Core.setup_board(board_id) do
          Core.get_board(board_id)
        end

      found_board |> Enum.empty? == false ->
        Core.get_board(board_id)

      true ->
        raise :not_connected
    end
    |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end
end
