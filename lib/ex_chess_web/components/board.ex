defmodule ExChessWeb.Board do
  @moduledoc """
  Chess board live component.
  """
  use ExChessWeb, :live_component
 
  def render(assigns) do
    ~H"""
    <div class="flex flex-row bg-blue-300 h-80 w-80 justify-center items-center">
      <div class="grid grid-cols-8 grid-rows-8 gap-0 hover:cursor-pointer">
        <%= for {location, _occupant} = square <- @display do %>
          <.live_component
            module={ExChessWeb.Square}
            id={location}
            square={square}
            game_id={@id}
            game={@game}
            current_user={@current_user}
            board={@board}
          />
        <% end %>
      </div>
    </div>
    """
  end
end
