defmodule ExChess.Core.Boards.Board do
  @moduledoc"""
  Contains the functions for creating and maintaining a chess board.
  """
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
  @doc"""
  Initiate new blank chess board.
  """
  def init(_) do
    {:ok, create_board()}
  end

  @doc"""
  Sets the chess board by colored sides (black and white).
  """
  def handle_call({:set_board, color}, _from, board) do
    updated_board = setup_board(board, color)

    {:reply, updated_board, updated_board}
  end

  @doc"""
  Gets the current state of the chess board.
  """
  def handle_call(:get_board, _from, board) do
    {:reply, board, board}
  end

  @doc"""
  Moves a chess piece from one location to another based on
  x and y coordinate pairs for both from and to variables.
  """
  def handle_call({:move_piece, from, to}, _from, board) do
    updated_board = move(board, from, to)

    {:reply, updated_board, updated_board}
  end

  def handle_info({"update_backend", board}, _board) do
    {:noreply, board}
  end

  @doc"""
  Creates a chess board using x and y coordinate list. The coordinate
  list is located inside a tuple in the form of {[x, y], occupancy}.
  The occupancy is determined by the chess piece or else it is nil.
  All tuples are pushed into a empty Map in the for up
  [x, y] => occupant.
  """
  defp create_board do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  @doc"""
  Sets up the chess board by taking an empty chess board and
  with the corresponding type of chess piece then reduces the
  the chess boards down to the one board.
  """
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

  @doc"""
  Updates the chess board by finding a piece at the location
  specified by the from variable, then updating the from and
  to location with the occupant.
  """
  defp move(board, from, to) do
    {_location, occupant} = something = Enum.find(board, fn {location, _occupant} -> location == from end)

    %{board | from => nil, to => occupant}
  end

  @doc"""
  Merges all the chess boards and corresponding pieces.
  """
  defp merge_boards(board, acc) do
    Map.merge(acc, board, fn _b, v1, v2 ->
      if v1 == nil, do: v2, else: v1
    end)
  end
end
