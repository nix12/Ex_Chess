defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  alias ExChess.Core.Boards.Board
  alias ExChess.Core.Pieces.{Piece, Rook}

  @doc"""
  Takes an ID to create a unique chess board.
  """
  def create_board(id) do
    Board.start_link(id)
  end

  @doc"""
  Get current state of identified chess board.
  """
  def get_board(id) do
    Board.get_board(id)
  end

  @doc"""
  Setup both sides of identified board.
  """
  def set_board(id) do
    Board.set_board(id, "white")
    Board.set_board(id, "black")
  end

  @doc"""
  Move piece on identified board from one square to another.
  """
  def move_piece(id, from, to) do
    Board.move_piece(id, from, to)
  end
end
