defmodule ExChess.Core.Schema.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Core.Schema.{Chessboard, Participants}

  @derive {Jason.Encoder, only: [
    :id, 
    :current_turn, 
    :winner,
    :chessboard,
    :participants
  ]} 

  @primary_key {:id, :binary, []}

  schema "games" do
    field :chessboard_id, :integer
    field :current_turn, :string
    field :winner, :string

    has_one :chessboard, Chessboard
    has_one :participants, Participants
    has_many :users, through: [:participants, :user]

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = game, attrs \\ %{}) do
    game
    |> cast(attrs, [:id, :current_turn,  :winner])
    |> cast_assoc(:participants, with: &ExChess.Core.Schema.Participants.changeset/2)
    |> cast_assoc(:chessboard, with: &ExChess.Core.Schema.Chessboard.changeset/2)
    |> validate_required([:id])
  end
end
