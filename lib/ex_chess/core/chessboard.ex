defmodule ExChess.Core.Chessboard do
  alias ExChess.Repo
  alias ExChess.Core.Schema.Chessboard
  alias ExChess.Core.Pieces.{Pawn, Rook, Knight, Bishop, Queen, King}

  @types [Rook, Bishop, Queen, Knight, King, Pawn]

  @doc """
  Creates a chessboard.

  ## Examples

      iex> create_board(%{field: value})
      {:ok, %Chessboard{}}

      iex> create_board%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_board(attrs \\ %{}) do
    %Chessboard{}
    |> Chessboard.changeset(attrs)
    |> Repo.insert()
  end

  def new_board do
    for(x <- 1..8, y <- 1..8, into: %{}, do: {[y, x], nil})
  end

  def setup_board(chessboard, color) do
    Enum.map(chessboard, fn square ->
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

  @doc """
  Updates a chessboard.

  ## Examples

      iex> update_boardBoard(chessboard, %{field: new_value})
      {:ok, %Game{}}

      iex> update_boardBoard(chessboard, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_board(%Chessboard{} = chessboard, attrs) do
    chessboard
    |> Chessboard.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chessboard.

  ## Examples

      iex> delete_board(chessboard)
      {:ok, %Chessboard{}}

      iex> delete_board(chessboard)
      {:error, %Ecto.Changeset{}}

  """
  def delete_board(%Chessboard{} = chessboard) do
    Repo.delete(chessboard)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chessboard changes.

  ## Examples

      iex> change_board(chessboard)
      %Ecto.Changeset{data: %Chessboard{}}

  """
  def change_board(%Chessboard{} = chessboard, attrs \\ %{}) do
    Chessboard.changeset(chessboard, attrs)
  end

  def place_piece(piece, {location, _} = square) do
    if location in piece.start_location do
      {location, piece} 
    else
      square
    end
  end

  def get_location(chessboard, current_location) do
    Enum.find(chessboard, fn {location, _} -> current_location == location end)
  end

  def check_placement(player, occupant) do
    if player.color != occupant.color do
      occupant
    else
      raise :illegal_move
    end
  end
  
  def move(chessboard, player, from, to) do
    {_, occupant} = square = Enum.find(chessboard, fn {location, _occupant} -> 
      location == from 
    end) 
      
    %{chessboard | from => nil, to => occupant}
  end

  def available_moves(chessboard, {_, %{type: type}} = square, player) do
    case type |> String.to_existing_atom() do
      Rook ->
        Rook.range_movement(chessboard, square, player)
        |> compose_moves()

      Bishop ->
        Bishop.range_movement(chessboard, square, player)
        |> compose_moves()

      Queen ->
        Queen.range_movement(chessboard, square, player)
        |> compose_moves()

      Pawn ->
        Pawn.range_movement(chessboard, square, player)
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
