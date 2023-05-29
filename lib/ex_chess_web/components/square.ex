defmodule ExChessWeb.Square do
  use ExChessWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      id={"#{@id}-square"}
      class={["h-8 w-8 border-solid border-2 border-black", "select-none", color_board(@location)]}
      phx-hook="Sortable"
      data-list_id={@id}
      data-group="squares"
    >
      <%= case elem(@square, 1) do %>
        <% nil -> %>
          <span></span>
        <% piece -> %>
          <span class="text-3xl content-center" data-id={@location}><%= raw(piece.icon) %></span>
      <% end %>
    </div>
    """
  end

  def handle_event("reposition", params, socket) do
    IO.inspect(params, label: "PARAMS")

    {:noreply, socket}
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  defp color_board(location) do
    if location |> Enum.at(0) |> rem(2) != location |> Enum.at(1) |> rem(2),
      do: "bg-gray-600",
      else: "bg-white"
  end
end
