defmodule ExChessWeb.GameLive.Show do
  @moduledoc """
  Shows active game.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
  alias ExChess.Repo
  alias ExChess.Core

  @impl true
  def mount(%{"game_id" => game_id}, _session, socket) do
    current_user = socket.assigns.current_user

    tracking_params = %{
      id: current_user.email,
      username: current_user.username,
      status: current_user.status
    }

    ExChessWeb.Presence.track_user(game_id, current_user.email, tracking_params)
    ExChessWeb.Presence.subscribe(game_id)

    game =
      game_id
      |> Core.get_game!()
      |> Repo.preload([:chessboard, :participants])

    socket =
      socket
      |> stream(:presences, ExChessWeb.Presence.list_online_users(game_id))
      |> assign(game_id: game_id)
      |> assign(game: game)
      |> assign(color: get_color(game, current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("complete_turn", _, socket) do
    send(self(), {"broadcast_move"})

    {:noreply, socket}
  end

  def handle_event("reset_board", _, socket) do
    send(self(), {:reset})

    {:noreply, socket}
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

  @doc """
  Broadcast movement of positions to all connected users.
  """
  def handle_info({"broadcast_move"}, socket) do
    board = socket.assigns.game.chessboard.board
    prev_board = socket.assigns.game.chessboard.prev_board

    game =
      socket.assigns.game_id
      |> Core.get_game!()
      |> Repo.preload(:chessboard)

    chessboard_changeset =
      Ecto.Changeset.change(game.chessboard, %{
        board: board,
        prev_board: prev_board
      })

    game
    |> Core.save_game(chessboard_changeset)
    |> then(fn _ ->
      PubSub.broadcast!(
        ExChess.PubSub,
        "game:" <> socket.assigns.game_id,
        {"update_board", board, prev_board}
      )
    end)

    {:noreply, socket}
  end

  def handle_info({:reset}, socket) do
    prev_board = socket.assigns.game.chessboard.prev_board

    send(self(), {"update_board", prev_board, %{}})

    {:noreply, socket}
  end

  def handle_info({"update_game", game}, socket) do
    IO.puts("UPDATE GAME")

    {:noreply, assign(socket, :game, game)}
  end

  def handle_info({"update_board", updated_board, prev_board}, socket) do
    IO.puts("UPDATE BOARD")

    game =
      socket.assigns.game
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:chessboard, board: updated_board, prev_board: prev_board)
      |> Ecto.Changeset.apply_action!(:update)

    send(self(), {"update_game", game})

    {:noreply, socket}
  end

  # def handle_info({:put_flash, type, message}, socket) do
  #   {:noreply,
  #    socket
  #    |> put_flash(type, message)
  #    |> push_event("reset_board", %{board: socket.assigns.game.chessboard.board})}
  # end

  defp get_color_from_participants(participants, current_user) do
    case current_user.id do
      id when id == participants.player_id ->
        participants.player_color

      id when id == participants.opponent_id ->
        participants.opponent_color
    end
  end

  defp get_color(game, current_user) do
    game
    |> Repo.preload(:participants)
    |> Map.get(:participants)
    |> get_color_from_participants(current_user)
  end
end
