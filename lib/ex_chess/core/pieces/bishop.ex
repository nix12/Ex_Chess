defmodule ExChess.Core.Pieces.Bishop do
  defstruct [
    :color,
    :icon,
    move_set: [[1, 1], [-1, 1], [-1, -1], [1, -1]]
  ]

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2657;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265D;" end)
    end
  end
end
