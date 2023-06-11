defmodule ExChess.Core.Pieces.Queen do
  @moduledoc"""
  Queen struct
  """
  defstruct [
    :color,
    :icon,
    move_set: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]
  ]

  def create_piece(color) do
    %__MODULE__{color: color}
  end

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2655;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265B;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[1, 5]]
    else
      [[8, 5]]
    end
  end
end
