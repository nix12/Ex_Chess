defmodule ExChess.Repo.Migrations.CreateGamesUsersTable do
  use Ecto.Migration

  def change do
    create table(:games_users) do
      add :game_id, references(:users, type: :binary_id, on_delete: :delete_all)
      add :user_id, references(:games, type: :binary_id, on_delete: :delete_all)
    end
  end
end
