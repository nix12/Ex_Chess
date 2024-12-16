defmodule ExChess.CoreTest do
  use ExChess.DataCase

  alias ExChess.Core

  describe "games" do
    alias ExChess.Core.Schema.Game

    import ExChess.CoreFixtures

    @invalid_attrs %{in_check?: nil, checkmate?: nil, board: nil}

    test "list_games/0 returns all games" do
      game = game_fixture()
      assert Core.list_games() == [game]
    end

    test "get_game!/1 returns the game with given id" do
      game = game_fixture()
      assert Core.get_game!(game.id) == game
    end

    test "create_game/1 with valid data creates a game" do
      valid_attrs = %{in_check?: true, checkmate?: true, board: %{}}

      assert {:ok, %Game{} = game} = Core.create_game(valid_attrs)
      assert game.in_check? == true
      assert game.checkmate? == true
      assert game.board == %{}
    end

    test "create_game/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Core.create_game(@invalid_attrs)
    end

    test "update_game/2 with valid data updates the game" do
      game = game_fixture()
      update_attrs = %{in_check?: false, checkmate?: false, board: %{}}

      assert {:ok, %Game{} = game} = Core.update_game(game, update_attrs)
      assert game.in_check? == false
      assert game.checkmate? == false
      assert game.board == %{}
    end

    test "update_game/2 with invalid data returns error changeset" do
      game = game_fixture()
      assert {:error, %Ecto.Changeset{}} = Core.update_game(game, @invalid_attrs)
      assert game == Core.get_game!(game.id)
    end

    test "delete_game/1 deletes the game" do
      game = game_fixture()
      assert {:ok, %Game{}} = Core.delete_game(game)
      assert_raise Ecto.NoResultsError, fn -> Core.get_game!(game.id) end
    end

    test "change_game/1 returns a game changeset" do
      game = game_fixture()
      assert %Ecto.Changeset{} = Core.change_game(game)
    end
  end
end
