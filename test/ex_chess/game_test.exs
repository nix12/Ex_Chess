defmodule ExChess.GameTest do
  use ExChess.DataCase

  alias ExChess.Core.Game

  describe "games" do
    alias ExChess.Core.Schema.Game, as: GameSchema

    import ExChess.CoreFixtures

    @invalid_attrs %{current_turn: 1, winner: 1}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Game.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Game.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{current_turn: "valid", winner: "valid"}

      assert {:ok, %GameSchema{} = game} = Game.create_game(valid_attrs)
      assert game.current_turn == "valid"
      assert game.winner == "valid"
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Game.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{current_turn: "valid", winner: "valid"}

      assert {:ok, %GameSchema{} = game} =
               Game.update_game(game, update_attrs)

      assert game.current_turn == "valid"
      assert game.winner == "valid"
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Game.update_game(game, @invalid_attrs)
      assert game == Game.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %GameSchema{}} = Game.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Game.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Game.change_game(game)
    end
  end
end
