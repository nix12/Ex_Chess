defmodule ExChess.Core.Pieces.King do
  @moduledoc"""
  King struct
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
      Map.update!(piece, :icon, fn _ -> "&#x2654;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265A;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[1, 4]]
    else
      [[8, 4]]
    end
  end
end
