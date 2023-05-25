defmodule ExChessWeb.Square do
  use ExChessWeb, :live_component

  def render(assigns) do
    ~H"""
    <div phx-click="click" class="h-8 w-8 border-solid border-2 border-black">
      <%= case elem(@square, 1) do %>
        <% nil -> %>
          <span></span>
        <% _piece -> %>
          <span class="text-3xl content-center"><%= raw(elem(@square, 1).icon) %></span>
      <% end %>
    </div>
    """
  end
end
