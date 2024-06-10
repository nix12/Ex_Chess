defmodule ExChessWeb.Board do
  @moduledoc """
  Chess board live component.
  """
  use ExChessWeb, :live_component
 
  def render(assigns) do
    ~H"""
    <div class="w-5/12 h-auto">
      <div class="flex flex-row flex-row-reverse flex-wrap gap-0 bg-blue-300 h-1/8 w-1/8 justify-center items-center">
        <%= for {location, _occupant} = square <- @display do %>
          <.live_component
            module={ExChessWeb.Square}
            id={location}
            square={square}
            game_id={@id}
            game={@game}
            current_user={@current_user}
            board={@board}
            meta={@meta}
          />
        <% end %>
      </div>
    </div>
    """
  end
end
