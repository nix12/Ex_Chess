defmodule ExChess.Core.Pieces.Knight do
  @moduledoc """
  Knight struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)

  def move_set(), do: [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]

  def icon(:white), do: "&#x2658;"
  def icon(:black), do: "&#x265E;"

  def start_location(:white), do: [[1, 2], [1, 7]]
  def start_location(:black), do: [[8, 2], [8, 7]]
end
