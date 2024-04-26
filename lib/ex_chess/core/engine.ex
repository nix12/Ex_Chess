defmodule ExChess.Core.Engine do
  @moduledoc """
  Mechanics for game engine.
  """
  defstruct [
    players: [],
    current_turn: nil,
    in_check?: false,
    checkmate?: false,
    winner: "",
    move_record: []
  ]
  

  def new(game_id) do
    %__MODULE__{
      players: [],
      current_turn: nil,
      in_check?: false,
      checkmate?: false,
      winner: "",
      move_record: []
    }
  end
end