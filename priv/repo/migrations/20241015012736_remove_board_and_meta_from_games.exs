defmodule ExChess.Repo.Migrations.RemoveBoardAndMetaFromGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :board
      remove :meta
    end
  end
end
