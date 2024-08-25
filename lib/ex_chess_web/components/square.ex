defmodule ExChessWeb.Square do
  @moduledoc"""
  Render chess board squares.p
  """
  use ExChessWeb, :live_component

  alias ExChess.Core

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
        id={id(@square)}
        :if={can_show_icon?(@square)} 
        phx-hook="Highlight"
        class="text-3xl content-center" 
        data-id={Jason.encode!(@id)}
      >
        <%= raw(show_icon(@square)) %>
      </span>
    </div>
    """
  end

  @doc"""
  Receives message from drag and drop actions in the client. Next,
  the position params are converted to usable lists to update the
  server and broadcast changes.
  """
  def handle_event("reposition", params, socket) do
    %{"id" => from, "to" => %{"list_id" => to}} = params
    from = Jason.decode!(from)
    to = Jason.decode!(to)
    current_user = socket.assigns.current_user
    board = socket.assigns.board
    player = socket.assigns.game.meta.player
    opponent = socket.assigns.game.meta.opponent
    player_id = player.user.user_data.id
    opponent_id = opponent.user.user_data.id

    updated_board = 
      case current_user.id do
        id when id == player_id ->
          Core.move_piece(player, board, from, to)

        id when id == opponent_id ->
          Core.move_piece(opponent, board, from, to)
      end
    
    send(self(), {"broadcast_move", updated_board})

    {:noreply, socket}
  end

  def handle_event("highlight", params, socket) do
    [location, type] = String.split(params, " ")
    type = Jason.decode!(type) |> key_to_atom()
    location = Jason.decode!(location)
    current_user = socket.assigns.current_user
    board = socket.assigns.board
    player = socket.assigns.game.meta.player
    opponent = socket.assigns.game.meta.opponent
    player_id = player.user.user_data.id
    opponent_id = opponent.user.user_data.id

    available_moves = 
      case current_user.id do
        id when id == player_id ->
          Core.available_moves(board, {location, type}, player)

        id when id == opponent_id ->
          Core.available_moves(board, {location, type}, opponent)
      end

    {:noreply, push_event(socket, "highlight_moves_#{Jason.encode!(location)}", %{available_moves: available_moves})}
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

  defp key_to_atom(map) do
    map
    |> Map.to_list()
    |> Enum.reduce(%{}, fn
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end
end
