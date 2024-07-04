defmodule ExChess.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary, primary_key: true, null: false
      add :in_check?, :boolean, default: false, null: false
      add :checkmate?, :boolean, default: false, null: false
      add :board, :map, null: false
      add :player_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :opponent_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :current_turn, :string
      add :winner, :string

      timestamps()
    end

    create unique_index(:games, [:id])
    create index(:games, [:player_id])
    create index(:games, [:opponent_id])
    create index(:games, [:current_turn])
    create index(:games, [:winner])
  end
end
