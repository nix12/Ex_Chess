defmodule ExChess.Core.Boards.Board do
  use GenServer

  # Client
  def start_link(id) do
    GenServer.start_link(__MODULE__, [], name: {:via, Registry, {ExChessGameRegistry, id}})
  end

  def build_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:build_board})
  end

  def move(id, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:move, from, to})
  end

  def print_board(id) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, id}}, {:print_board})
  end

  # Server
  def init(_) do
    {:ok, []}
  end

  def handle_call({:build_board}, _from, _board) do
    board = create_board()

    {:reply, {:ok, board}, board}
  end

  def handle_info({:set_piece, location, piece}, board) do
    updated_board =
      for {loc, _} = square <- board,
          do: if(loc == location, do: put_elem(square, 1, piece), else: square)

    {:noreply, updated_board}
  end

  def handle_call({:print_board}, _from, board) do
    {:reply, board, board}
  end

  def handle_info({:move, from, to, piece}, board) do
    {:noreply, move_piece(board, from, to, piece)}
  end

  # The formation for the tuple is {x location, y location, occupant}
  defp create_board, do: for(x <- 1..8, y <- 1..8, do: {{x, y}, nil})

  defp move_piece(board, from, to, piece) do
    Enum.into(board, [], fn {location, occupant} = square ->
      case location do
        # location == from && occupant == nil ->
        #   # Replace piece
        #   square

        location when location == from and occupant != nil ->
          remove_piece(board, from)
          |> IO.inspect(label: "REMOVE")

        location when location == to and occupant == nil ->
          add_piece(board, to, piece)
          |> IO.inspect(label: "ADD")

        _ ->
          square
      end
    end)
  end

  defp add_piece(board, location, piece) do
    Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    |> then(fn square ->
      put_elem(square, 1, piece)
    end)
  end

  defp remove_piece(board, location) do
    Enum.find_value(board, fn {_location, occupant} -> {location, occupant} end)
    |> then(fn square ->
      put_elem(square, 1, nil)
    end)
  end

  # replace_piece
end
