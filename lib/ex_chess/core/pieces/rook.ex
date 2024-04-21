defmodule ExChess.Core.Pieces.Rook do
  @moduledoc """
  Rook struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)

  def move_set(), do: [[1, 0], [-1, 0], [0, 1], [0, -1]]

  def icon(:white), do: "&#x2656;"
  def icon(:black), do: "&#x265C;"

  def start_location(:white), do: [[1, 1], [1, 8]]
  def start_location(:black), do: [[8, 1], [8, 8]]
end
