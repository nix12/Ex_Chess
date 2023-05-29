defmodule ExChess.Core do
  alias ExChess.Core.Boards.Board
  alias ExChess.Core.Pieces.{Piece, Rook}

  def create_board(id) do
    Board.start_link(id)
  end

  def get_board(id) do
    Board.get_board(id)
  end

  def set_board(id) do
    Board.set_board(id, "white")
    Board.set_board(id, "black")
  end

  def create_piece(name, piece) do
    Piece.start_link(name, piece)
  end
end
