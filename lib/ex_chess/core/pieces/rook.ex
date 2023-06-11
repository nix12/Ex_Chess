defmodule ExChess.Core.Pieces.Rook do
  @moduledoc"""
  Rook struct
  """
  defstruct [:color, :icon, move_set: [[1, 0], [-1, 0], [0, 1], [0, -1]]]

  def create_piece(color) do
    %__MODULE__{color: color}
  end

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2656;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265C;" end)
    end
  end

  def start_location(piece) do
    if piece.color == "white" do
      [[1, 1], [1, 8]]
    else
      [[8, 1], [8, 8]]
    end
  end
end
