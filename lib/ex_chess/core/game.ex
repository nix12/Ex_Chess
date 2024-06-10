defmodule ExChess.Core.Game do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Accounts.User

  schema "games" do
    field :in_check?, :boolean, default: false
    field :checkmate?, :boolean, default: false
    field :board, :map
    field :player, :id
    field :opponent, :id
    field :current_turn, :id
    field :winner, :id

    has_many :users, User

    timestamps()
  end

  @doc false
  def changeset(game, attrs) do
    game
    |> cast(attrs, [:in_check?, :checkmate?, :board])
    |> validate_required([:in_check?, :checkmate?])
  end
end
