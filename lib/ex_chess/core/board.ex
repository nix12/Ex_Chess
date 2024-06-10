defmodule ExChess.Core.Board do
  @moduledoc """
  Contains the functions for creating and maintaining a chess board.
  """
  alias ExChess.Core.Pieces.{Piece, Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Rook]

  def new do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  def setup_board(board, color) do
    Enum.map(board, fn square ->
      Enum.map(@types, fn type ->
        type.new() 
        |> type.color(color)
        |> type.set_icon()
        |> type.start_location()
        |> type.move_set()
        |> place_piece(square)
      end) 
      |> Enum.sort()
      |> List.last()
    end)
    |> Enum.into(%{})
  end

  def place_piece(piece, {location, _} = square) do
    if location in piece.start_location do
      {location, piece} 
    else
      square
    end
  end

  def get_location(board, current_location) do
    Enum.find(board, fn {location, _} -> current_location == location end)
  end
  
  def move(player, board, from, to) do
    {_, occupant} = square = Enum.find(board, fn {location, _occupant} -> 
      location == from 
    end) 
      
    if to in available_moves(board, square, player) do
      %{board | from => nil, to => occupant}
    else
      raise :illegal_move
    end
  end

  def available_moves(board, {_, type} = square, player) do
    case get_type(type) do
      ExChess.Core.Pieces.Rook = piece ->
        piece.range_movement(board, square, player)
        |> compose_moves()

      _ ->
        generate_move_list(square)
    end
  end

  def compose_moves(movements) do
    for(ranges <- movements, location <- ranges, into: [], do: location)
    |> Enum.reject(&is_nil/1)
  end
  
  def generate_move_list({[location_x, location_y], occupant}) do
    for [x, y] <- occupant.move_set, do: [x + location_x, y + location_y]
  end

  def get_type(type) do
    if is_atom(type) do
      type
    else
      type.__struct__
    end
  end
end
