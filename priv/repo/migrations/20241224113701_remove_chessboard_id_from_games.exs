defmodule ExChess.Repo.Migrations.RemoveChessboardIdFromGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      remove :chessboard_id
    end
  end
end
