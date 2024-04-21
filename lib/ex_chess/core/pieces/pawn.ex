defmodule ExChess.Core.Pieces.Pawn do
  @moduledoc """
  Pawn struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]

  def icon(:white), do: "&#x2659;"
  def icon(:black), do: "&#x265F;"

  def start_location(:white), do: [[2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8]]
  def start_location(:black), do: [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8]]
end
