defmodule ExChessWeb.LobbyLive do
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
        IO.puts("LOBBY CONNECTED")
        current_user = socket.assigns[:current_user]

        ExChessWeb.Presence.subscribe(current_user.id)

        socket
      else
        socket
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

    chessboard = %{board: board}

    {:ok, game} =
      %{chessboard: chessboard, participants: participants}
      |> Game.create_game()
      |> tap(fn {:ok, game} ->
        Participants.navigate_opponent(game.id, opponent_id)
      end)

    {:noreply, redirect(socket, to: ~p"/game/#{game.id}")}
  end

  @impl true
  def handle_info({"navigate", %{game_id: game_id, opponent_id: opponent_id}}, socket) do
    IO.inspect(game_id, label: "GAME ID")
    IO.inspect(opponent_id, label: "OPPONENT ID")
    IO.inspect(socket.assigns.current_user.id, label: "CURRENT USER")

    socket =
      if socket.assigns.current_user.id == opponent_id do
        redirect(socket, to: ~p"/game/#{game_id}")
      else
        socket
      end

    {:noreply, socket}
  end
end
