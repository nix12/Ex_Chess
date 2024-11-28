defmodule ExChess.Core.Pieces.Pawn do
  @moduledoc """
  Pawn struct
  """
  alias ExChess.Core.Chessboard

  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]}

  defstruct type: __MODULE__, color: nil, icon: nil, start_location: nil

  def new(), do: %__MODULE__{}
  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0]]

  def set_icon(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | icon: "&#x2659;"}
  def set_icon(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | icon: "&#x265F;"}

  def start_location(%__MODULE__{color: "white"} = piece),
    do: %__MODULE__{
      piece
      | start_location: [[2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8]]
    }

  def start_location(%__MODULE__{color: "black"} = piece),
    do: %__MODULE__{
      piece
      | start_location: [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8]]
    }

  def range_movement(board, {location, _}, current_player_color) do
    [
      pawn_regular(board, location, current_player_color, []),
      pawn_range(board, location, current_player_color, [])
    ]
  end

  def pawn_regular(_, _, _, acc \\ [])
  def pawn_regular(_, [y, _], "black", acc) when y >= 5, do: acc

  def pawn_regular(board, [y, _] = location, "black", _acc) when y <= 7 do
    {[location_y, location_x], _} =
      case Chessboard.get_location(board, location) do
        {_, %{"color" => "black"}} = piece ->
          {location, piece}

        {_, %{"color" => "white"}} ->
          {location, nil}
      end

    possible_moves =
      for [y, x] <- [[-1, -1], [-1, 0], [-1, 1]], do: [y + location_y, x + location_x]

    for move <- possible_moves do
      case Chessboard.get_location(board, move) do
        {_, %{"color" => "white"}} ->
          move

        _ ->
          nil
      end
    end
  end

  def pawn_regular(_, [y, _], "white", acc) when y >= 4, do: acc

  def pawn_regular(board, [y, _] = location, "white", _acc) when y >= 2 do
    {[location_y, location_x], _} =
      case Chessboard.get_location(board, location) do
        {_, %{"color" => "black"}} = piece ->
          {location, piece}

        {_, %{"color" => "white"}} ->
          {location, nil}
      end

    possible_moves = for [y, x] <- [[1, -1], [1, 0], [1, 1]], do: [y + location_y, x + location_x]

    for move <- possible_moves do
      case Chessboard.get_location(board, move) do
        {_, %{"color" => "black"}} ->
          move

        _ ->
          nil
      end
    end
  end

  def pawn_range(_, _, _, acc \\ [])
  def pawn_range(_, [y, _], "black", acc) when y <= 5, do: acc

  def pawn_range(board, [y, x], "black" = current_user_color, acc) when y <= 7 do
    vertical = [y - 1, x]
    {location, occupant} = Chessboard.get_location(board, vertical)

    case occupant do
      %{color: color} when color == current_user_color ->
        [nil | acc]

      %{color: color} when color != current_user_color ->
        [location | acc]

      nil ->
        pawn_range(board, location, current_user_color, [location | acc])
    end
  end

  def pawn_range(_, [y, _], "white", acc) when y >= 4, do: acc

  def pawn_range(board, [y, x], "white" = current_user_color, acc) when y >= 2 do
    vertical = [y + 1, x]
    {location, occupant} = Chessboard.get_location(board, vertical)

    case occupant do
      %{color: color} when color == current_user_color ->
        [nil | acc]

      %{color: color} when color != current_user_color ->
        [location | acc]

      nil ->
        pawn_range(board, location, current_user_color, [location | acc])
    end
  end
end
