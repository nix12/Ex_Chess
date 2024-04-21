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
    %{"id" => from, "to" => %{"list_id" => to}} = decoded_params = %{params | 
      "id" => Jason.decode!(params["id"]), 
      "to" => %{params["to"] | 
        "list_id" => Jason.decode!(params["to"]["list_id"])
      }
    }
    updated_board = Core.move_piece(socket.assigns.board_id, from, to)
        
    PubSub.broadcast(
      ExChess.PubSub,
      "board:" <> socket.assigns.board_id,
      {"movement", decoded_params, updated_board}
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
end
