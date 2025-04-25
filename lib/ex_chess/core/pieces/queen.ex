defmodule ExChess.Core.Pieces.Queen do
  @moduledoc """
  Queen struct
  """
  alias ExChess.Core.Chessboard

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]}

  defstruct type: __MODULE__, color: nil, icon: nil, start_location: nil

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set, do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]

  def set_icon(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | icon: "&#x2655;"}
  def set_icon(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | icon: "&#x265B;"}

  def start_location(%__MODULE__{color: "white"} = piece),
    do: %__MODULE__{piece | start_location: [[1, 5]]}

  def start_location(%__MODULE__{color: "black"} = piece),
    do: %__MODULE__{piece | start_location: [[8, 5]]}

  def range_movement(board, {location, _}, current_player_color) do
    [
      horizontal_greater(board, location, current_player_color, []),
      horizontal_lesser(board, location, current_player_color, []),
      vertical_greater(board, location, current_player_color, []),
      vertical_lesser(board, location, current_player_color, []),
      upper_right(board, location, current_player_color, []),
      upper_left(board, location, current_player_color, []),
      lower_left(board, location, current_player_color, []),
      lower_right(board, location, current_player_color, [])
    ]
  end

  def horizontal_greater(_, _, _, acc \\ [])
  def horizontal_greater(_, [_, x], _, acc) when x >= 8, do: acc

  def horizontal_greater(board, [y, x], current_player_color, acc) when x >= 1 do
    horizontal = [y, x + 1]
    {location, occupant} = Chessboard.get_location(board, horizontal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        # Take piece function needs to be built
        [location | acc]

      nil ->
        horizontal_greater(board, location, current_player_color, [location | acc])
    end
  end

  def horizontal_lesser(_, _, _, acc \\ [])
  def horizontal_lesser(_, [_, x], _, acc) when x <= 1, do: acc

  def horizontal_lesser(board, [y, x], current_player_color, acc) when x <= 8 do
    horizontal = [y, x - 1]
    {location, occupant} = Chessboard.get_location(board, horizontal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        # Take piece function needs to be built
        [location | acc]

      nil ->
        horizontal_lesser(board, location, current_player_color, [location | acc])
    end
  end

  def vertical_greater(_, _, _, acc \\ [])
  def vertical_greater(_, [y, _], _, acc) when y >= 8, do: acc

  def vertical_greater(board, [y, x], current_player_color, acc) when y >= 1 do
    vertical = [y + 1, x]
    {location, occupant} = Chessboard.get_location(board, vertical)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        # Take piece function needs to be built
        [location | acc]

      nil ->
        vertical_greater(board, location, current_player_color, [location | acc])
    end
  end

  def vertical_lesser(_, _, _, acc \\ [])
  def vertical_lesser(_, [y, _], _, acc) when y <= 1, do: acc

  def vertical_lesser(board, [y, x], current_player_color, acc) when y <= 8 do
    vertical = [y - 1, x]
    {location, occupant} = Chessboard.get_location(board, vertical)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        [location | acc]

      nil ->
        vertical_lesser(board, location, current_player_color, [location | acc])
    end
  end

  def upper_right(_, _, _, acc \\ [])
  def upper_right(_, [y, x], _, acc) when x >= 8 or y >= 8, do: acc

  def upper_right(board, [y, x], current_player_color, acc) when x >= 1 or y >= 1 do
    diagonal = [y + 1, x + 1]
    {location, occupant} = Chessboard.get_location(board, diagonal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        [location | acc]

      nil ->
        upper_right(board, location, current_player_color, [location | acc])
    end
  end

  def lower_left(_, _, _, acc \\ [])
  def lower_left(_, [y, x], _, acc) when x <= 1 or y <= 1, do: acc

  def lower_left(board, [y, x], current_player_color, acc) when x <= 8 or y <= 8 do
    diagonal = [y - 1, x - 1]
    {location, occupant} = Chessboard.get_location(board, diagonal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        [location | acc]

      nil ->
        lower_left(board, location, current_player_color, [location | acc])
    end
  end

  def upper_left(_, _, _, acc \\ [])
  def upper_left(_, [y, x], _, acc) when x <= 1 or y >= 8, do: acc

  def upper_left(board, [y, x], current_player_color, acc) when x <= 8 or y >= 1 do
    diagonal = [y + 1, x - 1]
    {location, occupant} = Chessboard.get_location(board, diagonal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        [location | acc]

      nil ->
        upper_left(board, location, current_player_color, [location | acc])
    end
  end

  def lower_right(_, _, _, acc \\ [])
  def lower_right(_, [y, x], _, acc) when x >= 8 or y <= 1, do: acc

  def lower_right(board, [y, x], current_player_color, acc) when x >= 1 or y <= 8 do
    diagonal = [y - 1, x + 1]
    {location, occupant} = Chessboard.get_location(board, diagonal)

    case occupant do
      %{"color" => color} when color == current_player_color ->
        [nil | acc]

      %{"color" => color} when color != current_player_color ->
        [location | acc]

      nil ->
        lower_right(board, location, current_player_color, [location | acc])
    end
  end
end
