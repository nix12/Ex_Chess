defmodule ExChess.Core do
  @moduledoc"""
  Contains functions for core of the chess application.
  """
  import Ecto.Query, only: [from: 2]

  alias ExChess.Repo
  alias Phoenix.PubSub
  alias ExChess.Accounts.User
  alias ExChess.Core.{Game, Board}

  @doc"""
  Start new game.
  """
  def new_game(game_id) do
    case get_game(game_id) do
      nil ->
        %Game{id: game_id, board: build_board()}
        
      game -> 
        game = key_to_atom(game)

        board = 
          game.board
          |> key_to_list() 
          |> format_occupant()

        %Game{game | board: board}
    end
  end

  def add_player(%Game{player_id: nil} = game, current_user) do
    %{game | player_id: current_user.id} |> Repo.preload(:player)
  end

  def add_player(%Game{player_id: player_id} = game, _current_user) do
    %{game | player_id: player_id} |> Repo.preload(:player)
  end

  def find_opponent(%Game{opponent_id: nil} = game, current_user) do
    opponent = search_for_opponent(current_user)

    navigate_opponent(game, opponent)
    %{game | opponent_id: opponent.id} |> Repo.preload(:opponent)
  end

  def find_opponent(%Game{opponent_id: opponent_id} = game, _current_user) do
    %{game | opponent_id: opponent_id} |> Repo.preload(:opponent)
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

  def add_meta(game, player_color, opponent_color) do
    player = game.player
    opponent = game.opponent

    if game == nil do
      %{game | meta: %{player: nil, opponent: nil}}
    else
      %{game | 
        meta: %{
          player: %{
            user: %{
              user_data: player, 
              color: player_color
            }
          }, 
          opponent: %{
            user: %{
              user_data: opponent, 
              color: opponent_color
            }
          }
        }
      }
    end  
  end

  def save_game(game) do
    Repo.insert!(
      game,
      on_conflict: :replace_all,
      conflict_target: [:id]
    )
  end
  
  @doc"""
  Setup both sides of identified board.
  """
  def build_board() do
    Board.new()
    |> Board.setup_board(:white)
    |> Board.setup_board(:black)
  end

  @doc"""
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

  @doc"""
  Returns the list of games.

  ## Examples

      iex> list_games()
      [%Game{}, ...]

  """
  def list_games do
    Repo.all(Game)
  end

  @doc"""
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(123)
      %Game{}

      iex> get_game!(456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(id), do: Repo.get!(Game, id)
  def get_game(id), do: Repo.get(Game, id)

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

  # Utility Functions
  defp key_to_list(map) do
    for {k, v} <- map, into: %{}, do: {:erlang.binary_to_list(k), v}
  end

  defp key_to_atom(map) do
    map
    |> Map.to_list()
    |> Enum.reduce(%{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  defp format_occupant(board) do
    for {location, occupant} <- board, into: %{} do
      if occupant != nil do
        {location, key_to_atom(occupant)}
      else
        {location, nil}
      end
    end  
  end
end
