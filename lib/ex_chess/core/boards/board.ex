defmodule ExChess.Core.Boards.Board do
  use GenServer

  alias ExChess.Core.Pieces.{Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Pawn, Rook, Knight, Bishop, Queen, King]

  # Client
  def start_link(id) do
    GenServer.start_link(__MODULE__, %{}, name: {:via, Registry, {ExChessGameRegistry, id}})
  end

  def get_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, :get_board)
  end

  def set_board(id, color) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:set_board, color})
  end

  def move_piece(id, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:move_piece, from, to})
  end

  # Server
  def init(_) do
    {:ok, create_board()}
  end

  def handle_call({:set_board, color}, _from, board) do
    updated_board = setup_board(board, color)

    {:reply, updated_board, updated_board}
  end

  def handle_call(:get_board, _from, board) do
    {:reply, board, board}
  end

  def handle_call({:move_piece, from, to}, _from, board) do
    updated_board = move(board, from, to)

    {:reply, updated_board, updated_board}
  end

  def handle_info({"update_backend", board}, _board) do
    IO.puts("UPDATED BOARD")
    {:noreply, board}
  end

  # The formation for the tuple is {[x location, y location], occupant} then converted to a map
  defp create_board do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  defp setup_board(board, color) do
    for pieces <- @types, {location, _occupant} <- board do
      piece = pieces.create_piece(color) |> pieces.set_icon()

      if location in pieces.start_location(piece) do
        Map.update!(board, location, fn _ -> piece end)
      else
        board
      end
    end
    |> Enum.reduce(%{}, fn board, acc ->
      merge_boards(board, acc)
    end)
  end

  defp move(board, from, to) do
    {_location, occupant} = something = Enum.find(board, fn {location, _occupant} -> location == from end)

    %{board | from => nil, to => occupant}
  end

  defp merge_boards(board, acc) do
    Map.merge(acc, board, fn _b, v1, v2 ->
      if v1 == nil, do: v2, else: v1
    end)
  end
end
