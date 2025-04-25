defmodule ExChess.Core do
  @moduledoc """
  Contains functions for core of the chess application.
  """
  alias ExChess.Repo
  alias ExChess.Core.{Game, Chessboard, Participants}

  def change_board(board, attrs) do
    Chessboard.change_board(board, attrs)
  end

  def get_game!(game_id) do
    Game.get_game!(game_id)
  end

  def save_game(game, attrs) do
    game
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:chessboard, attrs)
    |> Repo.update()
  end

  @doc """
  Move piece on identified board from one square to another.
  """
  def move_piece(board, player, from, to) do
    Chessboard.move(board, player, from, to)
  end

  def available_moves(board, square, player) do
    Chessboard.available_moves(board, square, player)
  end
end
