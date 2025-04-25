defmodule ExChess.Core.Pieces.King do
  @moduledoc"""
  King struct
  """
  @derive {Jason.Encoder, only: [:type, :color, :icon, :start_location]} 

  defstruct [type: __MODULE__, color: nil, icon: nil, start_location: nil]

  def new(), do: %__MODULE__{}

  def color(piece, color), do: %__MODULE__{piece | color: color}

  def move_set(), do: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]
  
  def set_icon(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | icon: "&#x2654;"}
  def set_icon(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | icon: "&#x265A;"}

  def start_location(%__MODULE__{color: "white"} = piece), do: %__MODULE__{piece | start_location: [[1, 4]]}
  def start_location(%__MODULE__{color: "black"} = piece), do: %__MODULE__{piece | start_location: [[8, 4]]}
end
