defmodule ExChess.Repo.Migrations.CreateGames do
  use Ecto.Migration

  def change do
    create table(:games, primary_key: false) do
      add :id, :binary_id, primary_key: true, null: false
      add :in_check?, :boolean, default: false, null: false
      add :checkmate?, :boolean, default: false, null: false
      add :board, :map
      add :player, references(:users, type: :binary_id, on_delete: :delete_all)
      add :opponent, references(:users, type: :binary_id, on_delete: :delete_all)
      add :current_turn, references(:users, type: :binary_id, on_delete: :delete_all)
      add :winner, references(:users, type: :binary_id, on_delete: :delete_all)

      timestamps()
    end

    create index(:games, [:player])
    create index(:games, [:opponent])
    create index(:games, [:current_turn])
    create index(:games, [:winner])
  end
end
