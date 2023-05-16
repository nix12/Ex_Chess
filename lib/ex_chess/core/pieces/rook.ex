defmodule ExChess.Core.Pieces.Rook do
  defstruct [:color, :icon, move_set: [[1, 0], [-1, 0], [0, 1], [0, -1]]]

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "\u265C" end)
    else
      Map.update!(piece, :icon, fn _ -> "\u2656" end)
    end
  end
end
