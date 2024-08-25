defmodule ExChess.Core.Board do
  @moduledoc"""
  Contains the functions for creating and maintaining a chess board.
  """
  alias ExChess.Core.Pieces.{Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Rook, Bishop, Queen, Knight, King, Pawn]

  def new do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[y, x], nil})
  end

  def setup_board(board, color) do
    Enum.map(board, fn square ->
      Enum.map(@types, fn type ->
        type.new() 
        |> type.color(color)
        |> type.start_location()
        |> type.set_icon()
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

  def available_moves(board, {_, %{type: type}} = square, player) do
    case type |> String.to_existing_atom() do
      Rook ->
        Rook.range_movement(board, square, player)
        |> compose_moves()

      Bishop ->
        Bishop.range_movement(board, square, player)
        |> compose_moves()

      Queen ->
        Queen.range_movement(board, square, player)
        |> compose_moves()

      Pawn ->
        Pawn.range_movement(board, square, player)
        |> compose_moves()

      _ ->
        generate_move_list(square)
    end
  end

  def compose_moves(movements) do
    for(ranges <- movements, location <- ranges, into: [], do: location)
    |> Enum.reject(&is_nil/1)
  end
  
  def generate_move_list({[location_y, location_x], %{type: type}}) do
    type = type |> String.to_existing_atom()

    for [y, x] <- type.move_set() do
      calculate_y = y + location_y 
      calculate_x = x + location_x

      if calculate_y <= 8 and calculate_y >= 1 and calculate_x <= 8 and calculate_x >= 1 do
        [calculate_y, calculate_x]
      else
        nil
      end
    end
    |> Enum.reject(&is_nil/1)
  end
end
