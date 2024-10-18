defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  alias Phoenix.PubSub
  alias ExChess.Repo
  alias ExChess.Core.{Game, Chessboard, Participants}

  @doc """
  Finds an existing game or starts a new game.
  """
  def new_game(game_id, current_user) do  
    case Game.get_game(game_id) do
      nil -> 
        opponent_id = Participants.search_for_opponent(current_user) |> Map.get(:id)
        participants = %{player_id: current_user.id, opponent_id: opponent_id}
        
        board = 
          Chessboard.new_board
          |> Chessboard.setup_board("black")
          |> Chessboard.setup_board("white")

        chessboard = %{board: board}

        {:ok, new_game} = Game.create_game(%{
          id: game_id, 
          chessboard: chessboard,
          participants: participants
        })

        Participants.navigate_opponent(game_id, opponent_id)

        # PubSub.broadcast!(ExChess.PubSub, "game:" <> game_id, {"update_game", new_game})

        {:ok, new_game}

      found_game ->
        # PubSub.broadcast!(ExChess.PubSub, "game:" <> game_id, {"update_game", found_game})

        updated_board =
          found_game
          |> Repo.preload(:chessboard)
          |> board()
          |> converted_board_keys()

        {:ok, %{found_game | chessboard: %{board: updated_board}} |> Repo.preload(:participants)}
    end
  end

  defp converted_board_keys(board) do
    for {location, occupant} <- board, into: %{}, do: {:erlang.binary_to_list(location), occupant}
  end

  defp board(game) do
    game  
    |> Map.get(:chessboard)
    |> Map.get(:board)
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
  def move_piece(player, board, from, to) do
    Chessboard.move(player, board, from, to)
  end

  def available_moves(board, square, player) do
    Chessboard.available_moves(board, square, player)
  end
end
