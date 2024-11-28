defmodule ExChess.Core do
  @moduledoc """
  Contains functions for core of the chess application.
  """
  alias ExChess.Repo
  alias ExChess.Core.{Game, Chessboard, Participants}

  @doc """
  Finds an existing game or starts a new game.

  ## Examples

      iex> new_game("string_id", %User{})
      {:ok, %Game{}}

  """
  def new_game(game_id, current_user) do
    case Game.get_game(game_id) do
      nil ->
        opponent_id = Participants.search_for_opponent(current_user) |> Map.get(:id)
        participants = %{player_id: current_user.id, opponent_id: opponent_id}

        board =
          Chessboard.new_board()
          |> Chessboard.setup_board("black")
          |> Chessboard.setup_board("white")

        chessboard = %{board: board}

        %{id: game_id, chessboard: chessboard, participants: participants}
        |> Game.create_game()
        |> tap(fn _ ->
          Participants.navigate_opponent(game_id, opponent_id)
        end)

      found_game ->
        found_game = found_game |> Repo.preload([:chessboard, :participants])

        updated_board =
          found_game
          |> get_in([Access.key!(:chessboard), Access.key!(:board)])
          |> converted_board_keys()

        updated_game =
          update_in(found_game, [Access.key!(:chessboard), Access.key!(:board)], fn _ ->
            updated_board
          end)

        {:ok, updated_game}
    end
  end

  defp converted_board_keys(board) do
    for {location, occupant} <- board, into: %{}, do: {:erlang.binary_to_list(location), occupant}
  end

  ##############################################################

  def save_game(game) do
    Repo.insert!(
      game,
      on_conflict: :replace_all,
      conflict_target: [:id]
    )
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
