defmodule ExChess.Core.Pieces.Bishop do
  @moduledoc"""
  Bishop struct
  """
  defstruct [
    :color,
    :icon,
    move_set: [[1, 1], [-1, 1], [-1, -1], [1, -1]]
  ]

  def create_piece(color) do
    %__MODULE__{color: color}
  end

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2657;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265D;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[1, 3], [1, 6]]
    else
      [[8, 3], [8, 6]]
    end
  end
end
