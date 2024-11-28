defmodule ExChess.Core.Participants do
  alias Phoenix.PubSub
  alias ExChess.Repo
  alias ExChess.Core.Schema.Participants
  alias ExChess.Core.Query.ParticipantsQuery

  @doc """
  Returns the list of participantss.

  ## Examples

      iex> list_participantss()
      [%Participants{}, ...]

  """
  def list_participantss do
    Repo.all(Participants)
  end

  @doc """
  Gets a single participants.

  Raises `Ecto.NoResultsError` if the Participants does not exist.

  ## Examples

      iex> get_participants!(123)
      %Participants{}

      iex> get_participants!(456)
      ** (Ecto.NoResultsError)

  """
  def get_participants!(id), do: Repo.get!(Participants, id)
  def get_participants(id), do: Repo.get(Participants, id)

  @doc """
  Creates a participants.

  ## Examples

      iex> create_participants(%{field: value})
      {:ok, %Participants{}}

      iex> create_participants(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_participants(attrs \\ %{}) do
    %Participants{}
    |> Participants.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a participants.

  ## Examples

      iex> update_participants(participants, %{field: new_value})
      {:ok, %Participants{}}

      iex> update_participants(participants, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_participants(%Participants{} = participants, attrs) do
    participants
    |> Participants.changeset(attrs)
    |> Repo.update()
  end

  # @doc """
  # Deletes a participants.

  # ## Examples

  #     iex> delete_participants(participants)
  #     {:ok, %Participants{}}

  #     iex> delete_participants(participants)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_participants(%Participants{} = participants) do
  #   Repo.delete(participants)
  # end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking participants changes.

  ## Examples

      iex> change_participants(participants)
      %Ecto.Changeset{data: %Participants{}}

  """
  def change_participants(%Participants{} = participants, attrs \\ %{}) do
    Participants.changeset(participants, attrs)
  end

  # def assign_player(game, current_user) do
  #   Map.put(game, :player_id, current_user.id)
  # end

  # def find_opponent(game, current_user) do
  #   opponent = search_for_opponent(current_user)

  #   navigate_opponent(game, opponent)
  #   Map.put(game, :opponent_id, opponent.id)
  # end

  def navigate_opponent(game_id, opponent_id) do
    params = %{game_id: game_id, opponent_id: opponent_id}

    PubSub.broadcast!(ExChess.PubSub, "game:#{opponent_id}", {"navigate", params})
  end

  def search_for_opponent(current_user) do
    Repo.one(ParticipantsQuery.opponent_search_query(current_user))
  end
end
