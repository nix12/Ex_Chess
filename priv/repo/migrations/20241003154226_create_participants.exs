defmodule ExChess.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create table(:participants) do
      add :game_id, references(:games, on_delete: :nothing, type: :binary)
      add :player_id, references(:users, on_delete: :nothing, type: :binary_id)
      add :opponent_id, references(:users, on_delete: :nothing, type: :binary_id)

      timestamps()
    end

    create index(:participants, [:game_id])
    create index(:participants, [:player_id])
    create index(:participants, [:opponent_id])
  end
end
