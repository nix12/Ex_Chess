defmodule ExChess.Core.Pieces.Bishop do
  @moduledoc """
  Bishop struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1]]

  def icon(:white), do: "&#x2657;"
  def icon(:black), do: "&#x265D;"

  def start_location(:white), do: [[1, 3], [1, 6]]
  def start_location(:black), do: [[8, 3], [8, 6]]
end
