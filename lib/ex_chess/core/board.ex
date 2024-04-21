defmodule ExChess.Core.Board do
  @moduledoc """
  Contains the functions for creating and maintaining a chess board.
  """
  use GenServer
  alias ExChess.Core.Pieces.{Piece, Pawn, Rook, Knight, Bishop, Queen, King}
  alias ExChess.Core.Pieces.Piece

  @types [Pawn, Rook, Knight, Bishop, Queen, King]

  # Client
  def start_link(id) do
    GenServer.start_link(__MODULE__, %{}, name: {:via, Registry, {ExChessGameRegistry, id}})
  end

  def get_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, :get_board)
  end

  def setup_board(id, color) do
    GenServer.cast({:via, Registry, {ExChessGameRegistry, id}}, {:setup_board, color})
  end

  def move_piece(id, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:move_piece, from, to})
  end

  # Server
  @doc """
  Initiate new blank chess board.
  """
  def init(board) do
    {:ok, Map.put(board, :board, create_board())}
  end

  @doc """
  Sets the chess board by colored sides (black and white).
  """
  def handle_cast({:setup_board, color}, board) do
    {:noreply, %{board | board: build_board(board, color)}}
  end

  @doc """
  Gets the current state of the chess board.
  """
  def handle_call(:get_board, _from, board) do
    {:reply, board[:board], board}
  end

  @doc """
  Moves a chess piece from one location to another currentbased on
  x and y coordinate pairs for both from and to variables.
  """
  def handle_call({:move_piece, from, to}, _from, board) do
    updated_board = %{board | board: move(board, from, to)}

    {:reply, updated_board[:board], updated_board}
  end

  @doc """
  Handles the update of    IO.inspect(board, : "BOARD")
  the current state of chess board
  """
  def handle_info({"update_board", updated_board}, board) do
    {:noreply, %{board | board: updated_board}}
  end

  defp create_board do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  defp build_board(board, color) do
    Enum.map(board.board, fn square ->
      Enum.map(@types, fn type ->
        type 
        |> Piece.new(color) 
        |> place_piece(square)
      end) 
      |> Enum.sort()
      |> List.last()
    end)
    |> Enum.into(%{})
  end

  defp place_piece(piece, {location, _} = square) do
    if location in piece.start_location do
      {location, piece} 
    else
      square
    end
  end
  
  defp move(board, from, to) do
    {_, occupant} = Enum.find(board[:board], fn {location, _occupant} -> 
      location == from 
    end) 
    
    %{board[:board] | from => nil, to => occupant}
  end
end
