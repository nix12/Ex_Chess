defmodule ExChessWeb.Chessboard do
  @moduledoc """
  Chess board live component.
  """
  use ExChessWeb, :live_component

  def render(assigns) do
    ~H"""
    <div class="flex flex-row flex-row-reverse flex-wrap gap-0 bg-blue-300 h-1/8 w-1/8 justify-center">
      <%= for {location, _occupant} = square <- show_display(@game) do %>
        <.live_component
          module={ExChessWeb.Square}
          id={location}
          square={square}
          game_id={@id}
          game={@game}
          current_user={@current_user}
        />
      <% end %>
    </div>
    """
  end

  defp show_display(game) do
    game
    |> get_in([Access.key!(:chessboard), Access.key!(:board)])
    |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end
end
