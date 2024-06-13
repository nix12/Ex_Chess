defmodule ExChess.Core.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Accounts.User

  @primary_key {:id, :binary_id, []}

  schema "games" do
    field :in_check?, :boolean, default: false
    field :checkmate?, :boolean, default: false
    field :board, :map
    field :player, :id
    field :opponent, :id
    field :current_turn, :id
    field :winner, :id

    many_to_many :users, User, join_through: "games_users"

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:id, :in_check?, :checkmate?, :board])
    |> validate_required([:in_check?, :checkmate?])
  end
end
