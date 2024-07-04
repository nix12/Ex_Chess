defmodule ExChess.Repo.Migrations.AddGamesToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :game_id, references(:games, type: :binary, on_delete: :delete_all)
    end
    
    create index(:users, [:game_id])
  end
end
