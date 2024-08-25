defmodule ExChess.Core.Pieces.Pawn do
  @moduledoc"""
  Pawn struct
  """
  alias ExChess.Core.Board

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0]]
  
  def set_icon(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | icon: "&#x2659;"}
  def set_icon(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | icon: "&#x265F;"}

  def start_location(%__MODULE__{color: :white} = piece), do: %__MODULE__{piece | start_location: [[2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8]]}
  def start_location(%__MODULE__{color: :black} = piece), do: %__MODULE__{piece | start_location: [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8]]}

  def range_movement(board, {location, _}, player) do
    [pawn_regular(board, location, player, []), pawn_range(board, location, player, [])]
  end

  def pawn_regular(_, _, _, acc \\ [])
  def pawn_regular(_, [y, _], %{user: %{color: "black"}}, acc) when y <= 5, do: acc
  def pawn_regular(board, [y, x] = location, %{user: %{color: "black"}} = player, acc) when y <= 7 do
    # vertical = [y - 1, x]
    {[location_y, location_x], occupant} = Board.get_location(board, location)

    # case occupant do
    #   %{color: color} when color == player.user.color ->
    #     [nil | acc]

    #   %{color: color} when color != player.user.color ->
    #     [location | acc]

    #   nil -> 
        for [y, x] <- [[-1, -1], [-1, 0], [-1, 1]], do: [y + location_y, x + location_x]
    # end
  end
  def pawn_regular(_, [y, _], %{user: %{color: "white"}}, acc) when y >= 4, do: acc
  def pawn_regular(board, [y, x] = location, %{user: %{color: "white"}} = player, acc) when y >= 2 do
    # vertical = [y + 1, x]
    {[location_y, location_x] = location, occupant} = Board.get_location(board, location)

    # case occupant do
    #   %{color: color} when color == player.user.color ->
    #     [nil | acc]

    #   %{color: color} when color != player.user.color ->
    #     [location | acc]

    #   nil -> 
        for [y, x] <- [[1, -1], [1, 0], [1, 1]], do: [y + location_y, x + location_x]
    # end
  end

  def pawn_range(_, _, _, acc \\ [])
  def pawn_range(_, [y, _], %{user: %{color: "black"}}, acc) when y <= 5, do: acc
  def pawn_range(board, [y, x], %{user: %{color: "black"}} = player, acc) when y <= 7 do
    vertical = [y - 1, x]
    {location, occupant} = Board.get_location(board, vertical)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        [location | acc]

      nil -> 
        pawn_range(board, location, player, [location | acc])
    end
  end
  def pawn_range(_, [y, _], %{user: %{color: "white"}}, acc) when y >= 4, do: acc
  def pawn_range(board, [y, x], %{user: %{color: "white"}} = player, acc) when y >= 2 do
    vertical = [y + 1, x]
    {location, occupant} = Board.get_location(board, vertical)

    case occupant do
      %{color: color} when color == player.user.color ->
        [nil | acc]

      %{color: color} when color != player.user.color ->
        [location | acc]

      nil -> 
        pawn_range(board, location, player, [location | acc])
    end
  end
end
