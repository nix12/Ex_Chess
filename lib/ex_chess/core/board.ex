defmodule ExChess.Core.Board do
  @moduledoc """
  Contains the functions for creating and maintaining a chess board.
  """
  alias ExChess.Core.Pieces.{Piece, Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Pawn, Rook, Knight, Bishop, Queen, King]

  def new do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  def setup_board(board, color) do
    Enum.map(board, fn square ->
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

  def place_piece(piece, {location, _} = square) do
    if location in piece.start_location do
      {location, piece} 
    else
      square
    end
  end
  
  def move(board, from, to) do
    {_, occupant} = Enum.find(board, fn {location, _occupant} -> 
      location == from 
    end) 
    
    %{board | from => nil, to => occupant}
  end
end
