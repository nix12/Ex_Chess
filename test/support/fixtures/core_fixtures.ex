defmodule ExChess.CoreFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExChess.Core` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(attrs \\ %{}) do
    {:ok, game} =
      attrs
      |> Enum.into(%{
        board: %{},
        checkmate?: true,
        in_check?: true
      })
      |> ExChess.Core.Game.create_game()

    game
  end
end
