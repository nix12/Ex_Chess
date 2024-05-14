defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  alias Phoenix.PubSub
  alias ExChess.Core.{Engine, Board}

  @doc """
  Start new game.
  """
  def new_game(game_id, current_user) do
    Engine.new(game_id, current_user, &navigate_fn/3)
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
  def move_piece(player, board, from, to) do
    Board.move(player, board, from, to)
  end

  def available_moves(square) do
    Board.available_moves(square)
  end

  def legal_moves(player, board, moves_list) do
    Board.legal_moves(player, board, moves_list)
  end 

  def navigate_fn(game_id, current_user, opponent) do
    params = %{
      game_id: game_id, 
      players: [current_user, opponent]
    }

    PubSub.broadcast!(
      ExChess.PubSub,
      "lobby:*",
      {"navigate", params}
    )
  end
end
