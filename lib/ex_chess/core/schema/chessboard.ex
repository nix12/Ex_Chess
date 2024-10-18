defmodule ExChess.Core.Schema.Chessboard do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Core.Schema.Game

  schema "chessboards" do
    field :board, :map

    belongs_to :game, Game, type: :binary

    timestamps()
  end

  @doc false
  def changeset(board, attrs) do
    board
    |> cast(attrs, [:board])
    |> validate_required([:board])
  end
end
