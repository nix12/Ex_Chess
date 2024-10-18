defmodule ExChess.Repo.Migrations.AddColorToParticipants do
  use Ecto.Migration

  def change do
    alter table(:participants) do
      add :player_color, :string
      add :opponent_color, :string
    end
  end
end
