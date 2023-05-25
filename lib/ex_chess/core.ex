defmodule ExChess.Core do
  alias ExChess.Core.Boards.Board
  alias ExChess.Core.Pieces.{Piece, Rook}

  def create_board(id) do
    Board.start_link(id)
  end

  def build_board(id) do
    Board.build_board(id)
  end

  def set_board(id) do
    Board.set_board(id, "white")
    # Board.set_board(id, "black")
  end

  def print_board(id) do
    Board.print_board(id)
  end

  def create_piece(name, piece) do
    Piece.start_link(name, piece)
  end
end
