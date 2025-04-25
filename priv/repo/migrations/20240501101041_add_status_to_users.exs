defmodule ExChess.Repo.Migrations.AddStatusToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :status, :string, default: "offline"
    end
  end
end
