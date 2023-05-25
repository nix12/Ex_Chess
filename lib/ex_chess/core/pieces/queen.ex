defmodule ExChess.Core.Pieces.Queen do
  defstruct [
    :color,
    :icon,
    move_set: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]
  ]

  def set_icon(piece) do
    if piece.color == "white" do
      Map.update!(piece, :icon, fn _ -> "&#x2655;" end)
    else
      Map.update!(piece, :icon, fn _ -> "&#x265B;" end)
    end
  end
end
