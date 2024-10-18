defmodule ExChess.Core.Pieces.Knight do
  @moduledoc"""
  Knight struct
  """
  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}
  
  def move_set, do: [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]

  def set_icon(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | icon: "&#x2658;"}
  def set_icon(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | icon: "&#x265E;"}

  def start_location(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | start_location: [[1, 2 ], [1, 7]]}
  def start_location(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | start_location: [[8, 2], [8, 7]]} 
end
