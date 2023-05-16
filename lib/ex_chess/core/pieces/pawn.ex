defmodule ExChess.Core.Pieces.Pawn do
  defstruct [
    :color,
    :icon,
    move_set: [[1, 1], [-1, 1], [-1, -1], [1, -1], [1, 0], [-1, 0], [0, 1], [0, -1]]
  ]

  def set_icon do
    if %__MODULE__{}.color == "white" do
      Map.update!(%__MODULE__{}, :icon, fn _ -> "\u265F" end)
    else
      Map.update!(%__MODULE__{}, :icon, fn _ -> "\u2659" end)
    end
  end
end
