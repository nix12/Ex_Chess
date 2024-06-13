defmodule ExChessWeb.Square do
  @moduledoc """
  Render chess board squares.
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
    board = socket.assigns.board
    player = socket.assigns.meta.player
    opponent = socket.assigns.meta.opponent

    updated_board = 
      cond do
        current_user.id == player.user.user_data.id ->
          Core.move_piece(player, board, from, to)

        current_user.id == opponent.user.user_data.id ->
          Core.move_piece(opponent, board, from, to)

        true ->
          raise :player_not_eligible
      end
    
    send(self(), {"broadcast_move", updated_board})

    # Save chessboard after move

    {:noreply, socket}
  end

  def handle_event("highlight", params, socket) do
    <<x::8, y::8, _::8, type::binary>> = Jason.decode!(params) 
    type = type |> String.to_existing_atom()
    location = [x, y]
    current_user = socket.assigns.current_user
    board = socket.assigns.board
    player = socket.assigns.meta.player
    opponent = socket.assigns.meta.opponent

    available_moves = 
      cond do
        current_user.id == player.user.user_data.id ->
          Core.available_moves(board, {location, type}, player)

        current_user.id == opponent.user.user_data.id ->
          Core.available_moves(board, {location, type}, opponent)

        true ->
          raise :player_not_eligible
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

  defp id({location, occupant}), do: Jason.encode!("#{location}-#{occupant.__struct__}")
  
  defp can_show_icon?({_, occupant}) do
    if occupant != nil, do: true, else: false
  end

  defp show_icon({_, occupant}), do: occupant.icon
end
