defmodule ExChess.Core.Engine do
  @moduledoc """
  Mechanics for game engine.
  """
  defstruct [
    game_id: nil,
    players: [],
    current_turn: nil,
    board: nil, 
    viewers: [], 
    in_check?: false,
    checkmate?: false,
    winner: "",
    move_record: []
  ]
  

  def new(game_id, new_board) do
    %__MODULE__{
      game_id: game_id,
      players: [],
      current_turn: nil,
      board: new_board, 
      viewers: [], 
      in_check?: false,
      checkmate?: false,
      winner: "",
      move_record: []
    }
  end
end