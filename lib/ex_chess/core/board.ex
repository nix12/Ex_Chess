defmodule ExChess.Core.Board do
  @moduledoc """
  Contains the functions for creating and maintaining a chess board.
  """
  alias ExChess.Core.Pieces.{Piece, Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Pawn, Rook, Knight, Bishop, Queen, King]

  def new do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[x, y], nil})
  end

  def setup_board(board, color) do
    Enum.map(board, fn square ->
      Enum.map(@types, fn type ->
        type 
        |> Piece.new(color) 
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
    
    IO.inspect(legal_moves(player, board, available_moves(square)), label: "LEGAL")
    IO.inspect(to, label: "TO")
      
    if to in legal_moves(player, board, available_moves(square)) do
      %{board | from => nil, to => occupant}
    else
      raise :illegal_move
    end
  end

  def available_moves(square) do
    square
    |> generate_move_list()
    |> check_out_of_bounds()
  end

  def legal_moves(player, board, moves_list) do
    for move <- moves_list, into: [] do
      {location, occupant} = get_location(board, move)

      case occupant do
        occupant when occupant.color == player.color ->
          nil

        occupant when occupant.color != player.color ->
          location
          
        nil ->
          location

        _ -> 
          nil
      end
    end
    |> Enum.reject(&is_nil/1)
  end
  
  def generate_move_list({[location_x, location_y], occupant}) do
    for [x, y] <- occupant.move_set, do: [x + location_x, y + location_y]
  end

  def check_out_of_bounds(moves_list) do 
    Enum.filter(moves_list, fn [x, y] = move -> 
      if x >= 1 and x <= 8 and y >= 1 and y <= 8 do 
        move 
      else 
        nil
      end
    end)
  end
end
