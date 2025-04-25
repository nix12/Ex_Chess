defmodule ExChess.Repo.Migrations.MoveInCheckAndCheckmateToParticipants do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :in_check?
      remove :checkmate?
    end

    alter table(:participants) do
      add :in_check?, :boolean, default: false, null: false
      add :checkmate?, :boolean, default: false, null: false
    end
  end
end
