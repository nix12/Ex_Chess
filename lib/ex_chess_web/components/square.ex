defmodule ExChessWeb.Square do
  @moduledoc"""
  Render chess board squares.
  """
  use ExChessWeb, :live_component

  alias Phoenix.PubSub
  alias ExChess.Core

  def render(assigns) do
    ~H"""
    <div
      id={@id}
      class={["h-8 w-8 border-solid border-2 border-black", "select-none", color_board(@id)]}
      phx-hook="Sortable"
      data-list_id={Jason.encode!(@id)}
      data-group="squares"
    >
      <%= case elem(@square, 1) do %>
        <% nil -> %>
          <% nil %>
        <% piece -> %>
          <span class="text-3xl content-center" data-id={Jason.encode!(@id)}><%= raw(piece.icon) %></span>
      <% end %>
    </div>
    """
  end

  @doc"""
  Receives message from drag and drop actions in the client. Next,
  the position params are converted to usable lists to update the
  server and broadcast changes.
  """
  def handle_event("reposition", params, socket) do
    converted_params = params |> convert_values_to_list([])
    updated_board = Core.move_piece(socket.assigns.board_id, converted_params["id"], converted_params["list_id"])

    PubSub.broadcast(
      ExChess.PubSub,
      "board:" <> socket.assigns.board_id,
      {"movement", converted_params, updated_board}
    )

    {:noreply, socket}
  end

  @doc"""
  Colors chess boards alternating squares
  """
  defp color_board(location) do
    if location |> Enum.at(0) |> rem(2) != location |> Enum.at(1) |> rem(2) do
      "bg-gray-600"
    else
      "bg-white"
    end
  end

  defp convert_values_to_list([], acc), do: acc |> Enum.into(%{})

  defp convert_values_to_list([{k, v} | tail], acc) when v |> is_map() do
    [{_k2, v2} = h2 | _t2] = v |> Map.to_list()

    convert_values_to_list(v, [h2 | acc])
  end

  defp convert_values_to_list(params, acc) when params |> is_map() do
    [{k, v} | tail] = params |> Map.to_list()

    if v == "squares" or v |> is_integer() do
      convert_values_to_list(tail, [{k, v} | acc])
    else
      convert_values_to_list(tail, [{k, Jason.decode!(v)} | acc])
    end
  end

  defp convert_values_to_list([{k, v} | tail] = params, acc) when params |> is_list() do
    if v == "squares" or v |> is_integer() do
      convert_values_to_list(tail, [{k, v} | acc])
    else
      convert_values_to_list(tail, [{k, Jason.decode!(v)} | acc])
    end
  end

  defp convert_values_to_list([{k, v} | tail], acc) do
    convert_values_to_list(tail, [{k, v} | acc])
  end
end
