defmodule ExChessWeb.Square do
  @moduledoc """
  Render chess board squares.
  """
  use ExChessWeb, :live_component

  alias ExChess.{Repo, Core}

  def render(assigns) do
    ~H"""
    <div
      id={Jason.encode!(@id)}
      class={["h-8 w-8 border-solid border-2 border-black", "select-none", color_board(@id)]}
      phx-hook="Sortable"
      data-list_id={Jason.encode!(@id)}
      data-group="squares"
    >
      <span
        :if={can_show_icon?(@square)}
        id={id(@square)}
        phx-hook="Highlight"
        class="text-3xl content-center"
        data-id={Jason.encode!(@id)}
      >
        <%= raw(show_icon(@square)) %>
      </span>
    </div>
    """
  end

  @doc """
  Receives message from drag and drop actions in the client. Next,
  the position params are converted to usable lists to update the
  server and broadcast changes.
  """
  def handle_event("reposition", params, socket) do
    %{"id" => from, "to" => %{"list_id" => to}} = params
    from = Jason.decode!(from)
    to = Jason.decode!(to)
    current_user = socket.assigns.current_user

    prev_board =
      socket.assigns.game
      |> Repo.preload(:chessboard)
      |> get_in([Access.key!(:chessboard), Access.key!(:board)])
      |> check_conversion_board_keys()

    participants = socket.assigns.game.participants |> Repo.preload([:player, :opponent])

    updated_board =
      case current_user.id do
        id when id == participants.player_id ->
          Core.move_piece(prev_board, participants.player_color, from, to)

        id when id == participants.opponent_id ->
          Core.move_piece(prev_board, participants.opponent_color, from, to)
      end

    send(self(), {"update_board", updated_board, prev_board})

    {:noreply, socket}
  end

  def handle_event("highlight", params, socket) do
    [location, item] = String.split(params, " ")
    item = Jason.decode!(item)
    location = Jason.decode!(location)
    current_user = socket.assigns.current_user

    board =
      socket.assigns.game
      |> Repo.preload(:chessboard)
      |> get_in([Access.key!(:chessboard), Access.key!(:board)])
      |> check_conversion_board_keys()

    participants = socket.assigns.game.participants |> Repo.preload([:player, :opponent])

    available_moves =
      case current_user.id do
        id when id == participants.player_id ->
          Core.available_moves(board, {location, item}, participants.player_color)

        id when id == participants.opponent_id ->
          Core.available_moves(board, {location, item}, participants.opponent_color)
      end

    {:noreply,
     push_event(socket, "highlight_moves_#{Jason.encode!(location)}", %{
       available_moves: available_moves
     })}
  end

  # Colors chess boards alternating squares
  defp color_board(location) do
    if location |> Enum.at(0) |> rem(2) != location |> Enum.at(1) |> rem(2) do
      "bg-slate-400"
    else
      "bg-white"
    end
  end

  defp id({location, occupant}) do
    "#{Jason.encode!(location)} #{Jason.encode!(occupant)}"
  end

  defp can_show_icon?({_, occupant}) do
    if occupant != nil, do: true, else: false
  end

  defp show_icon({_, %{"icon" => icon}}), do: icon
  defp show_icon({_, occupant}), do: occupant.icon

  defp check_conversion_board_keys(board) do
    case board do
      %{<<1, 1>> => _} ->
        for {location, occupant} <- board,
            into: %{},
            do: {:erlang.binary_to_list(location), occupant}

      %{[1, 1] => _} ->
        board
    end
  end
end
