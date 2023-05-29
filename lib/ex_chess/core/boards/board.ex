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

  def count(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, :count)
  end

  def set_board(id, color) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:set_board, color})
  end

  def move(id, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:move, from, to})
  end

  # Server
  def init(_) do
    {:ok, create_board()}
  end

  def handle_call(:count, _from, board) do
    board =
      Enum.with_index(board, fn square, idx -> put_elem(square, 1, idx) end) |> Enum.reverse()

    {:reply, board, board}
  end

  def handle_call({:set_board, color}, _from, board) do
    updated_board = setup_board(board, color)

    {:reply, updated_board, updated_board}
  end

  def handle_call(:get_board, _from, board) do
    {:reply, board, board}
  end

  def handle_info({:move, from, to, piece}, board) do
    {:noreply, move_piece(board, from, to, piece)}
  end

  # The formation for the tuple is {[x location, y location], occupant} then converted to a map
  defp create_board do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  defp setup_board(board, color) do
    for pieces <- @types, {location, _occupant} <- board do
      piece = pieces.create_piece(color) |> pieces.set_icon()

      cond do
        location in pieces.start_location(piece) ->
          Map.update!(board, location, fn _ -> piece end)

        true ->
          board
      end
    end
    |> Enum.reduce(%{}, fn board, acc ->
      Map.merge(acc, board, fn _b, v1, v2 ->
        if v1 == nil, do: v2, else: v1
      end)
    end)
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
    # Enum.find(board, fn {location, _occupant} -> location end)

    # Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    # |> then(fn square ->
    #   Map.update!(board, location, fn _ -> piece end)
    # end)
  end

  defp remove_piece(board, location) do
    Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    |> then(fn square ->
      put_elem(square, 1, nil)
    end)
  end

  # replace_piece
end
