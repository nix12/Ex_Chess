defmodule ExChess.Core.Schema.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Repo
  alias ExChess.Accounts.User
  alias ExChess.Core.Schema.Chessboard
  alias ExChess.Core.Schema.Participants

  @derive {Jason.Encoder, only: [
    :id, 
    :current_turn, 
    :winner,
    :participants
  ]} 

  @primary_key {:id, :binary, []}

  schema "games" do
    field :chessboard_id, :integer
    field :current_turn, :string
    field :winner, :string

    # belongs_to :player, User, foreign_key: :player_id, type: :binary_id
    # belongs_to :opponent, User, foreign_key: :opponent_id, type: :binary_id
    
    # many_to_many :participants, User, join_through: "participants"

    # has_one :participants, through: [:users, :participants]
    # has_many :users, User
    # has_one :participants, through: [:users, :participants]

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
