defmodule ExChess.Core.Pieces.Bishop do
  @moduledoc"""
  Bishop struct
  """
  alias ExChess.Core.Chessboard

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1]]

  def set_icon(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | icon: "&#x2657;"}
  def set_icon(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | icon: "&#x265D;"}

  def start_location(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | start_location: [[1, 3], [1, 6]]}
  def start_location(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | start_location: [[8, 3], [8, 6]]}

  def range_movement(board, {location, _}, player) do
    [
      upper_right(board, location, player, []),
      upper_left(board, location, player, []),
      lower_left(board, location, player, []),
      lower_right(board, location, player, [])
    ]
  end

  def upper_right(_, _, _, acc \\ [])
  def upper_right(_, [y, x], _, acc) when x >= 8 or y >= 8, do: acc
  def upper_right(board, [y, x], player, acc) when x >= 1 or y >= 1 do
    diagonal = [y + 1, x + 1]
    {location, occupant} = Chessboard.get_location(board, diagonal)

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
    {location, occupant} = Chessboard.get_location(board, diagonal)

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
    {location, occupant} = Chessboard.get_location(board, diagonal)

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
    {location, occupant} = Chessboard.get_location(board, diagonal)

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
