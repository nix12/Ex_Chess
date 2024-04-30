defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  alias ExChess.Core.{Engine, Board}

  @doc """
  Start new game.
  """
  def new_game() do
    Engine.new()
  end

  @doc """
  Setup both sides of identified board.
  """
  def build_board() do
    Board.new()
    |> Board.setup_board(:white)
    |> Board.setup_board(:black)
  end

  @doc """
  Move piece on identified board from one square to another.
  """
  def move_piece(board, from, to) do
    Board.move(board, from, to)
  end

  def generate_list(square) do
    Board.generate_move_list(square)
  end

  def check_bounds(moves_list) do
    Board.check_out_of_bounds(moves_list)
  end 
end
