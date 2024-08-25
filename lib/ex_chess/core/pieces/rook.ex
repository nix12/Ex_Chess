defmodule ExChess.Core.Pieces.Rook do
  @moduledoc"""
  Rook struct
  """
  alias ExChess.Core.Board

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set(), do: [[1, 0], [-1, 0], [0, 1], [0, -1]]
  
  def set_icon(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | icon: "&#x2656;"}
  def set_icon(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | icon: "&#x265C;"}

  def start_location(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | start_location: [[1, 1], [1, 8]]}
  def start_location(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | start_location: [[8, 8], [8, 1]]}

  def range_movement(board, {location, _}, player) do
    [
      horizontal_greater(board, location, player, []),
      horizontal_lesser(board, location, player, []),
      vertical_greater(board, location, player, []),
      vertical_lesser(board, location, player, [])
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
        # Take piece function needs to be built
        [location | acc]

      nil -> 
        vertical_lesser(board, location, player, [location | acc])
    end
  end
end
