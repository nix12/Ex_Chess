defmodule ExChess.Repo.Migrations.AddMetaToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :meta, :map, default: nil
    end  
  end
end
