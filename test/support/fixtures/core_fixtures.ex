defmodule ExChess.CoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExChess.Game` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        current_turn: nil,
        winner: nil
      })
      |> ExChess.Core.Game.create_game()

    game
  end
end
