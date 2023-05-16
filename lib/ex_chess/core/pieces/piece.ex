defmodule ExChess.Core.Pieces.Piece do
  use GenServer

  def start_link(name, piece) do
    GenServer.start_link(__MODULE__, piece, name: {:via, Registry, {ExChessGameRegistry, name}})
  end

  def spawn_piece(name, board, location) do
    GenServer.call(
      {:via, Registry, {ExChessGameRegistry, name}},
      {:spawn_piece, board, location}
    )
  end

  def print_piece(name, piece) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, name}}, {:print_piece})
  end

  def move(name, board, from, to) do
    GenServer.call({:via, Registry, {ExChessGameRegistry, name}}, {:move, board, from, to})
  end

  def init(piece) do
    {:ok, piece}
  end

  def handle_call({:spawn_piece, board, location}, _from, piece) do
    [{pid, _}] =
      Registry.lookup(ExChessGameRegistry, board)
      |> IO.inspect()

    send(pid, {:set_piece, location, piece})
    {:reply, :ok, piece}
  end

  def handle_call({:move, board, from, to}, _from, piece) do
    [{pid, _}] = Registry.lookup(ExChessGameRegistry, board)

    send(pid, {:move, from, to, piece})
    {:reply, :ok, piece}
  end

  def handle_call({:print_piece}, _from, piece) do
    {:reply, piece, piece}
  end
end
