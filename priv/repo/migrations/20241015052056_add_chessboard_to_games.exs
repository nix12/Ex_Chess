defmodule ExChess.Repo.Migrations.AddChessboardToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :chessboard_id, references(:chessboards, on_delete: :delete_all)
    end

    create index(:games, [:chessboard_id])
  end
end
