defmodule ExChessWeb.GameLive.Show do
  @moduledoc """
  Shows active game.
  """
  use ExChessWeb, :live_view

  alias Phoenix.PubSub
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

    {:ok, game} = Core.new_game(game_id, current_user)

    socket =
      socket
      |> stream(:presences, ExChessWeb.Presence.list_online_users(game_id))
      |> assign(game_id: game_id)
      |> assign(game: game)
      |> assign(color: get_color(game, current_user))

    {:ok, socket}
  end

  @impl true
  def handle_event("dummy", params, socket) do
    IO.puts("DUMMY")
    IO.inspect(params, label: "PARAMS")
    {:noreply, socket}
  end

  def handle_event("complete_turn", _, socket) do
    send(self(), {"broadcast_move"})

    {:noreply, socket}
  end

  def handle_event("reset_board", _, socket) do
    IO.puts("RESET BOARD")
    # send(self(), {:reset})

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
    # updated_socket =
    #   update_in(
    #     socket.assigns,
    #     [Access.key!(:game), Access.key!(:chessboard), Access.key!(:board)],
    #     fn _ -> updated_board end
    #   )

    PubSub.broadcast!(
      ExChess.PubSub,
      "game:" <> socket.assigns.game_id,
      {"update_board", socket.assigns.game.chessboard.board}
    )

    {:noreply, socket}
  end

  def handle_info({:reset}, socket) do
    IO.puts("RESET")
    prev_board = socket.assigns.game.chessboard.prev_board
    IO.inspect(prev_board, label: "===PREV BOARD RESET===")
    send(self(), {"update_board", prev_board, %{}})

    {:noreply, socket}
  end

  def handle_info({"update_game", game}, socket) do
    IO.puts("UPDATE GAME")
    # IO.inspect(game.chessboard, label: "PREV BOARD")
    {:noreply, assign(socket, :game, game)}
  end

  def handle_info({"update_board", updated_board, prev_board}, socket) do
    # Core.save_game(updated_game)
    IO.puts("UPDATE BOARD")

    updated_socket =
      socket.assigns
      |> update_in(
        [Access.key!(:game), Access.key!(:chessboard), Access.key!(:board)],
        fn _ ->
          updated_board
        end
      )
      |> update_in(
        [Access.key!(:game), Access.key!(:chessboard), Access.key!(:prev_board)],
        fn _ ->
          prev_board
        end
      )

    send(self(), {"update_game", updated_socket.game})

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
    |> Map.get(:participants)
    |> get_color_from_participants(current_user)
  end
end
