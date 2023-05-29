defmodule ExChessWeb.Square do
  use ExChessWeb, :live_component

  def render(assigns) do
    ~H"""
    <div
      phx-click="click"
      class={["h-8 w-8 border-solid border-2 border-black", color_board(@location)]}
    >
      <%= case elem(@square, 1) do %>
        <% nil -> %>
          <span></span>
        <% piece -> %>
          <span class="text-3xl content-center"><%= raw(piece.icon) %></span>
      <% end %>
    </div>
    """
  end

  def color_board(location) do
    if location |> Enum.at(0) |> rem(2) != location |> Enum.at(1) |> rem(2),
      do: "bg-gray-600",
      else: "bg-white"
  end
end
