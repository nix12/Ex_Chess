defmodule ExChessWeb.Presence do
  @moduledoc """
  Provides presence tracking to channels and processes.

  See the [`Phoenix.Presence`](https://hexdocs.pm/phoenix/Phoenix.Presence.html)
  docs for more details.
  """
  use Phoenix.Presence,
    otp_app: :ex_chess,
    pubsub_server: ExChess.PubSub

  def init(_opts) do
    {:ok, %{}}
  end

  def fetch(_topic, presences) do
    for {key, %{metas: [meta | metas]}} <- presences, into: %{} do
      # user can be populated here from the database here we populate
      # the name for demonstration purposes
      {key, %{metas: [meta | metas], id: meta.id, user: %{name: meta.id}}}
    end
  end

  def handle_metas(topic, %{joins: joins, leaves: leaves}, presences, state) do
    for {user_id, presence} <- joins do
      user_data = %{id: user_id, user: presence.user, metas: Map.fetch!(presences, user_id)}
      msg = {__MODULE__, {:join, user_data}}
      Phoenix.PubSub.local_broadcast(ExChess.PubSub, "game:#{topic}", msg)
    end

    for {user_id, presence} <- leaves do
      metas =
        case Map.fetch(presences, user_id) do
          {:ok, presence_metas} -> presence_metas
          :error -> []
        end

      user_data = %{id: user_id, user: presence.user, metas: metas}
      msg = {__MODULE__, {:leave, user_data}}
      Phoenix.PubSub.local_broadcast(ExChess.PubSub, "game:#{topic}", msg)
    end

    {:ok, state}
  end

  def list_online_users(game_id), do: list(game_id) |> Enum.map(fn {_id, presence} -> presence end)

  def track_user(game_id, name, params), do: track(self(), game_id, name, params)

  def subscribe(game_id), do: Phoenix.PubSub.subscribe(ExChess.PubSub, "game:" <> game_id)
end
