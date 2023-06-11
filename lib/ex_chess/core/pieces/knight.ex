defmodule ExChess.Core.Pieces.Knight do
  @moduledoc"""
  Knight struct
  """
  defstruct [
    :color,
    :icon,
    move_set: [[1, 2], [1, -2], [-1, 2], [-1, -2], [2, 1], [2, -1], [-2, 1], [-2, -1]]
  ]

  def create_piece(color) do
    %__MODULE__{color: color}
  end

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2658;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265E;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[1, 2], [1, 7]]
    else
      [[8, 2], [8, 7]]
    end
  end
end
