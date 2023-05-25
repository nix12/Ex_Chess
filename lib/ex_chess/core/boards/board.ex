defmodule ExChess.Core.Boards.Board do
  use GenServer

  alias ExChess.Core.Pieces.{Pawn, King, Queen, Knight, Bishop, Rook}

  # Client
  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: {:via, Registry, {ExChessGameRegistry, id}})
  end

  def build_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:build_board})
  end

  def count(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, :count)
  end

  def set_board(id, color) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:set_board, color})
  end

  def move(id, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:move, from, to})
  end

  def print_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:print_board})
  end

  # Server
  def init(_) do
    {:ok, []}
  end

  def handle_call({:build_board}, _from, _board) do
    board = create_board()

    {:reply, board, board}
  end

  def handle_call(:count, _from, board) do
    board =
      Enum.with_index(board, fn square, idx -> put_elem(square, 1, idx) end) |> Enum.reverse()

    {:reply, board, board}
  end

  def handle_call({:set_board, color}, _from, board) do
    updated_board =
      Enum.reduce([Rook, Knight], [], fn pieces, acc ->
        setup_board(board, color, pieces) ++ acc
      end)
      |> IO.inspect()

    {:reply, updated_board, updated_board}
  end

  def handle_call({:print_board}, _from, board) do
    {:reply, board, board}
  end

  def handle_info({:move, from, to, piece}, board) do
    {:noreply, move_piece(board, from, to, piece)}
  end

  # The formation for the tuple is {[x location, y location], occupant}
  defp create_board do
    for(x <- 1..8, y <- 1..8, do: {[x, y], nil})
  end

  defp setup_board(board, color, pieces) do
    for {location, _occupant} = square <- board, into: [] do
      piece = pieces.create_piece(color) |> pieces.set_icon()

      cond do
        location in pieces.start_location(piece) ->
          add_piece(board, location, piece)

        true ->
          square
      end
    end
  end

  defp move_piece(board, from, to, piece) do
    Enum.into(board, [], fn {location, occupant} = square ->
      case location do
        # location == from && occupant == nil ->
        #   # Replace piece
        #   square

        location when location == from and occupant != nil ->
          remove_piece(board, from)

        location when location == to and occupant == nil ->
          add_piece(board, to, piece)

        _ ->
          square
      end
    end)
  end

  defp add_piece(board, location, piece) do
    Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    |> then(fn square ->
      put_elem(square, 1, piece)
    end)
  end

  defp remove_piece(board, location) do
    Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    |> then(fn square ->
      put_elem(square, 1, nil)
    end)
  end

  # replace_piece
end
