defmodule ExChess.Core.Pieces.Queen do
  @moduledoc"""
  Queen struct
  """
  alias ExChess.Core.Board

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}
  
  def move_set, do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]

  def set_icon(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | icon: "&#x2655;"}
  def set_icon(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | icon: "&#x265B;"}

  def start_location(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | start_location: [[1, 5]]}
  def start_location(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | start_location: [[8, 5]]}

  def range_movement(board, {location, _}, player) do
    [
      horizontal_greater(board, location, player, []),
      horizontal_lesser(board, location, player, []),
      vertical_greater(board, location, player, []),
      vertical_lesser(board, location, player, []),
      upper_right(board, location, player, []),
      upper_left(board, location, player, []),
      lower_left(board, location, player, []),
      lower_right(board, location, player, [])
    ]
  end

  def horizontal_greater(_, _, _, acc \\ [])
  def horizontal_greater(_, [_, x], _, acc) when x >= 8, do: acc
  def horizontal_greater(board, [y, x], player, acc) when x >= 1 do
    horizontal = [y, x + 1]
    {location, occupant} = Board.get_location(board, horizontal)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        # Take piece function needs to be built
        [location | acc]

      nil -> 
        horizontal_greater(board, location, player, [location | acc])
    end
  end

  def horizontal_lesser(_, _,  _, acc \\ [])
  def horizontal_lesser(_, [_, x], _, acc) when x <= 1, do: acc
  def horizontal_lesser(board, [y, x], player, acc) when x <= 8 do
    horizontal = [y, x - 1]
    {location, occupant} = Board.get_location(board, horizontal)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        # Take piece function needs to be built
        [location | acc]

      nil -> 
        horizontal_lesser(board, location, player, [location | acc])
    end
  end

  def vertical_greater(_, _, _, acc \\ [])
  def vertical_greater(_, [y, _], _, acc) when y >= 8, do: acc 
  def vertical_greater(board, [y, x], player, acc) when y >= 1 do
    vertical = [y + 1, x]
    {location, occupant} = Board.get_location(board, vertical)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        # Take piece function needs to be built
        [location | acc]

      nil -> 
        vertical_greater(board, location, player, [location | acc])
    end
  end

  def vertical_lesser(_, _, _, acc \\ [])
  def vertical_lesser(_, [y, _], _, acc) when y <= 1, do: acc
  def vertical_lesser(board, [y, x], player, acc) when y <= 8 do
    vertical = [y - 1, x]
    {location, occupant} = Board.get_location(board, vertical)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        [location | acc]

      nil -> 
        vertical_lesser(board, location, player, [location | acc])
    end
  end

  def upper_right(_, _, _, acc \\ [])
  def upper_right(_, [y, x], _, acc) when x >= 8 or y >= 8, do: acc 
  def upper_right(board, [y, x], player, acc) when x >= 1 or y >= 1 do
    diagonal = [y + 1, x + 1]
    {location, occupant} = Board.get_location(board, diagonal)

    case occupant do
      occupant when occupant.color == player.user.color ->
        [nil | acc]

      occupant when occupant.color != player.user.color ->
        [location | acc]

      nil -> 
        upper_right(board, location, player, [location | acc])
    end
  end

  def lower_left(_, _,  _, acc \\ [])
  def lower_left(_, [y, x], _, acc) when x <= 1 or y <= 1, do: acc
  def lower_left(board, [y, x], player, acc) when x <= 8 or y <= 8 do
    diagonal = [y - 1, x - 1]
    {location, occupant} = Board.get_location(board, diagonal)

    case occupant do
      occupant when occupant.color == player.user.color ->
        [nil | acc]

      occupant when occupant.color != player.user.color ->
        [location | acc]

      nil -> 
        lower_left(board, location, player, [location | acc])
    end
  end

  def upper_left(_, _, _, acc \\ [])
  def upper_left(_, [y, x], _, acc) when x <= 1 or y >= 8, do: acc
  def upper_left(board, [y, x], player, acc) when x <= 8 or y >= 1 do
    diagonal = [y + 1, x - 1]
    {location, occupant} = Board.get_location(board, diagonal)

    case occupant do
      occupant when occupant.color == player.user.color ->
        [nil | acc]

      occupant when occupant.color != player.user.color ->
        [location | acc]

      nil -> 
        upper_left(board, location, player, [location | acc])
    end
  end

  def lower_right(_, _, _, acc \\ [])
  def lower_right(_, [y, x], _, acc) when x >= 8 or y <= 1, do: acc
  def lower_right(board, [y, x], player, acc) when x >= 1 or y <= 8 do
    diagonal = [y - 1, x + 1]
    {location, occupant} = Board.get_location(board, diagonal)

    case occupant do
      occupant when occupant.color == player.user.color ->
        [nil | acc]

      occupant when occupant.color != player.user.color ->
        [location | acc]

      nil -> 
        lower_right(board, location, player, [location | acc])
    end
  end
end
