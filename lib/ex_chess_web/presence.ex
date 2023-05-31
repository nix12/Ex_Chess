defmodule MyAppWeb.Presence do
  use Phoenix.Presence,
    otp_app: :ex_chess,
    pubsub_server: ExChess.PubSub
end
