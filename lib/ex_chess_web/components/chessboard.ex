defmodule ExChessWeb.Chessboard do
  @moduledoc """
  Chess board live component.
  """
  use ExChessWeb, :live_component

  alias ExChess.Repo

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
    |> Repo.preload(:chessboard)
    |> get_in([Access.key!(:chessboard), Access.key!(:board)])
    |> check_conversion_board_keys()
    |> Enum.sort_by(fn {location, _} -> location end, :desc)
  end

  defp check_conversion_board_keys(board) do
    case board do
      %{<<1, 1>> => _} ->
        for {location, occupant} <- board,
            into: %{},
            do: {:erlang.binary_to_list(location), occupant}

      %{[1, 1] => _} ->
        board
    end
  end
end
