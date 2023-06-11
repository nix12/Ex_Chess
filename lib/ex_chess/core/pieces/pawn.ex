defmodule ExChess.Core.Pieces.Pawn do
  @moduledoc"""
  Pawn struct
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
      Map.update!(piece, :icon, fn _ -> "&#x2659;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265F;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[2, 1], [2, 2], [2, 3], [2, 4], [2, 5], [2, 6], [2, 7], [2, 8]]
    else
      [[7, 1], [7, 2], [7, 3], [7, 4], [7, 5], [7, 6], [7, 7], [7, 8]]
    end
  end
end
