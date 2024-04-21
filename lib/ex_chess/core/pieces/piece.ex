defmodule ExChess.Core.Pieces.Piece do
  @moduledoc """
  Contains functions for building a chess piece.
  """
  alias ExChess.Core.Pieces.{Pawn, Rook, Knight, Bishop, Queen, King}

  def new(type, color) do
    struct(type, [
      color: type.color(color), 
      icon: type.icon(color), 
      move_set: type.move_set(),
      start_location: type.start_location(color)
    ])
  end
end