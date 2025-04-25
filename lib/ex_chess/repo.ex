defmodule ExChess.Repo do
  use Ecto.Repo,
    otp_app: :ex_chess,
    adapter: Ecto.Adapters.Postgres
end
