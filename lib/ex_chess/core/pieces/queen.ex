defmodule ExChess.Core.Pieces.Queen do
  @moduledoc """
  Queen struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)
  
  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]

  def icon(:white), do: "&#x2655;"
  def icon(:black), do: "&#x265B;"

  def start_location(:white), do: [[1, 5]]
  def start_location(:black), do: [[8, 5]]
end
