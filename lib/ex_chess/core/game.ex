defmodule ExChess.Core.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Accounts.User

  @derive {Jason.Encoder, only: [
    :id, 
    :in_check?, 
    :checkmate?, 
    :board, 
    :current_turn, 
    :winner,
    :player_id,
    :opponent_id
  ]} 

  @primary_key {:id, :binary, []}

  schema "games" do
    field :in_check?, :boolean, default: false
    field :checkmate?, :boolean, default: false
    field :board, :map
    field :current_turn, :string
    field :winner, :string

    belongs_to :player, User, foreign_key: :player_id, type: :binary_id
    belongs_to :opponent, User, foreign_key: :opponent_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :in_check?, :checkmate?, :board, :player_id, :opponent_id])
    |> validate_required([:id, :in_check?, :checkmate?, :player_id, :opponent_id])
    |> unique_constraint(:id)
  end
end
