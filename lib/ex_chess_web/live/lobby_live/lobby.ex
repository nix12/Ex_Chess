defmodule ExChessWeb.LobbyLive.Lobby do
  @moduledoc """
  Handles initial connection to application
  """
  require FriendlyID

  use ExChessWeb, :live_view

  alias ExChess.Core.{Game, Chessboard, Participants}

  @impl true
  def mount(_params, _session, socket) do
    socket =
      if connected?(socket) do
        current_user = socket.assigns[:current_user]

        tracking_params = %{
          id: current_user.email,
          username: current_user.username,
          status: current_user.status
        }

        ExChessWeb.Presence.track_user("lobby", current_user.email, tracking_params)
        ExChessWeb.Presence.subscribe(current_user.id)

        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users("lobby"))
      else
        socket
        |> stream(:presences, [])
      end

    {:ok, socket}
  end

  @impl true
  def handle_event("create_game", _params, socket) do
    current_user = socket.assigns.current_user
    opponent_id = Participants.search_for_opponent(current_user) |> Map.get(:id)
    participants = %{player_id: current_user.id, opponent_id: opponent_id}

    board =
      Chessboard.new_board()
      |> Chessboard.setup_board("black")
      |> Chessboard.setup_board("white")

    chessboard = %{board: board, prev_board: nil}

    {:ok, game} =
      %{chessboard: chessboard, participants: participants}
      |> Game.create_game()
      |> tap(fn {:ok, game} ->
        Participants.navigate_opponent(game.id, opponent_id)
      end)

    {:noreply, redirect(socket, to: ~p"/game/#{game.id}")}
  end

  @impl true
  def handle_info({ExChessWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({ExChessWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  def handle_info({"navigate", %{game_id: game_id, opponent_id: opponent_id}}, socket) do
    socket =
      if socket.assigns.current_user.id == opponent_id do
        redirect(socket, to: ~p"/game/#{game_id}")
      else
        socket
      end

    {:noreply, socket}
  end
end
