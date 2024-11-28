defmodule ExChess.Core.Schema.Participants do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExChess.Accounts.Schema.User
  alias ExChess.Core.Schema.Game

  @derive {Jason.Encoder, only: [:player_id, :opponent_id]}

  schema "participants" do
    field :player_color, :string
    field :opponent_color, :string
    field :in_check?, :boolean, default: false
    field :checkmate?, :boolean, default: false

    belongs_to :game, Game, type: :binary
    belongs_to :player, User, foreign_key: :player_id, type: :binary_id
    belongs_to :opponent, User, foreign_key: :opponent_id, type: :binary_id

    timestamps()
  end

  @doc false
  def changeset(%__MODULE__{} = participants, attrs \\ %{}) do
    participants
    |> cast(attrs, [:player_id, :opponent_id, :player_color, :opponent_color])
    |> validate_required([:player_id, :opponent_id])
    |> prepare_changes(fn
      %Ecto.Changeset{action: :insert} = changeset ->
        set_colors(changeset)

      changeset ->
        changeset
    end)
  end

  def set_colors(game) do
    player_color = color()
    opponent_color = opponent_color(player_color)

    change(game, %{player_color: color(), opponent_color: opponent_color})
  end

  defp color() do
    if :rand.uniform(100) <= 50, do: "white", else: "black"
  end

  defp opponent_color(player_color) do
    case player_color do
      "white" ->
        "black"

      "black" ->
        "white"
    end
  end
end
