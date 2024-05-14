defmodule ExChess.Core.Engine do
  @moduledoc """
  Mechanics for game engine.
  """
  import Ecto.Query, only: [from: 2] 
  
  alias ExChess.Repo

  defstruct [
    game_id: nil,
    players: [],
    current_turn: nil,
    in_check?: false,
    checkmate?: false,
    winner: "",
    move_record: []
  ]
  

  def new(game_id, current_user, navigate_fn) do
    %__MODULE__{
      players: assign_players(game_id, current_user, navigate_fn),
      current_turn: nil,
      in_check?: false,
      checkmate?: false,
      winner: "",
      move_record: []
    }
  end

  def assign_players(game_id, current_user, navigate_fn) do
    current_user = Map.take(current_user, [:id, :username, :status, :email])
    player = Map.put(current_user, :color, assign_color())
    opposing_color = if player.color == :white, do: :black, else: :white
    opponent = Map.put(search_for_opponent(), :color, opposing_color)

    navigate_fn.(game_id, player, opponent)

    [player, opponent]
  end
  
  
  def assign_color() do
    random_number = :rand.uniform(50)

    if random_number < 50, do: :white, else: :black   
  end 

  # def search_for_opponent() do
  #   presence_list = ExChessWeb.Presence.list("*")

  #   {opponent, _} =
  #     presence_list
  #     |> Enum.filter(fn {_, %{metas: [metas | _]}} -> 
  #       metas.status == :online  
  #     end)  
  #     |> Enum.random()      game: game_id, 


  #   Accounts.get_user_by_email(opponent)
  # end

  def search_for_opponent() do
    Repo.one(opponent_seach_query())
  end

  # Search database for online player
  def opponent_seach_query() do
    from(
      u in "users",
      where: u.status == "online",
      select: %{id: u.id, username: u.username, email: u.email, status: u.status},
      order_by: fragment("RANDOM()"),
      limit: 1
    )
  end
end