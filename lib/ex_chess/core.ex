defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  import Ecto.Query, only: [from: 2]

  alias ExChess.Repo
  alias Phoenix.PubSub
  alias ExChess.Accounts.User
  alias ExChess.Core.{Game, Board}

  @doc """
  Start new game.
  """
  def new_game(game_id) do
    # case get_game!(game_id) do
    #   nil ->
        Map.update!(%Game{}, :id, fn id -> id == game_id end)

    #   game -> 
    #     game
    # end
  end

  def add_player(game, current_user) do
    %Game{game | player: current_user}
  end

  def find_opponent(game, current_user) do
    opponent = search_for_opponent(current_user)

    navigate_opponent(game, opponent)

    %Game{game | opponent: opponent}
  end

  def search_for_opponent(current_user) do
    Repo.one(opponent_seach_query(current_user))
  end

  # Search database for online player
  def opponent_seach_query(current_user) do
    from(
      u in User,
      where: u.status == :online and u.id != ^current_user.id,
      select: %{id: u.id, username: u.username, email: u.email, status: u.status},
      order_by: fragment("RANDOM()"),
      limit: 1
    )
  end

  # def save_game(game) do
    
  # end
  
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

  def available_moves(board, square, player) do
    Board.available_moves(board, square, player)
  end

  def navigate_opponent(%{id: game_id}, opponent) do
    params = %{
      game_id: game_id, 
      opponent: opponent
    }

    PubSub.broadcast!(ExChess.PubSub, "game:#{opponent.id}", {"navigate", params})
  end

################################################
  @doc """
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(%{field: value})
      {:ok, %Game{}}

      iex> create_game(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(attrs \\ %{}) do
    %Game{}
    |> Game.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a game.

  ## Examples

      iex> update_game(game, %{field: new_value})
      {:ok, %Game{}}

      iex> update_game(game, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_game(%Game{} = game, attrs) do
    game
    |> Game.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a game.

  ## Examples

      iex> delete_game(game)
      {:ok, %Game{}}

      iex> delete_game(game)
      {:error, %Ecto.Changeset{}}

  """
  def delete_game(%Game{} = game) do
    Repo.delete(game)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Game{} = game, attrs \\ %{}) do
    Game.changeset(game, attrs)
  end
end
