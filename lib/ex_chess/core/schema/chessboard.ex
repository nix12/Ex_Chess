defmodule ExChess.Core.Schema.Chessboard do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Core.Schema.Game

  @derive {Jason.Encoder, only: [:board, :prev_board]}

  schema "chessboards" do
    field :board, :map
    field :prev_board, :map, virtual: true

    belongs_to :game, Game, type: :binary, on_replace: :delete

    timestamps()
  end

  @doc false
  def changeset(chessboard, attrs \\ %{}) do
    chessboard
    |> cast(attrs, [:board, :prev_board])
    |> validate_required([:board])
  end
end
