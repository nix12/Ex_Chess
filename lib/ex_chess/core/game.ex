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
    :meta,
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
    field :meta, :map

    belongs_to :player, User, foreign_key: :player_id, type: :binary_id
    belongs_to :opponent, User, foreign_key: :opponent_id, type: :binary_id

    # embeds_one :meta, Meta do
    #   field :player, :map
    #   field :opponent, :map
    # end
    
    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = game, attrs \\ %{}) do
    game
    |> cast(attrs, [:id, :in_check?, :checkmate?, :board, :player_id, :opponent_id, :meta])
    # |> cast_embed(:meta, required: true)
    |> validate_required([:id, :in_check?, :checkmate?, :player_id, :opponent_id])
  end
end
