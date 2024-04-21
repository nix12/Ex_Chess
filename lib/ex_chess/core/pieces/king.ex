defmodule ExChess.Core.Pieces.King do
  @moduledoc """
  King struct
  """
  defstruct [color: nil, icon: nil, move_set: nil, start_location: nil]

  def color(color), do: %__MODULE__{color: color} |> Map.get(:color)

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]

  def icon(:white), do: "&#x2654;"
  def icon(:black), do: "&#x265A;"

  def start_location(:white), do: [[1, 4]]
  def start_location(:black), do: [[8, 4]]
end
