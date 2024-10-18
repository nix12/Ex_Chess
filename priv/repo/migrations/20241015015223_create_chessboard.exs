defmodule ExChess.Repo.Migrations.CreateChessboard do
  use Ecto.Migration

  def change do
    create table(:chessboards) do
      add :board, :map
      add :game_id, references(:games, type: :binary, on_delete: :delete_all)

      timestamps()
    end

    create index(:chessboards, [:game_id])
  end
end
