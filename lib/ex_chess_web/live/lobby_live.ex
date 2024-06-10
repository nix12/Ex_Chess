defmodule ExChessWeb.LobbyLive do
  @moduledoc """
  Handles initial connection to application
  """
  require FriendlyID

  use ExChessWeb, :live_view

  def mount(_params, _session, socket) do    
    socket =
      if connected?(socket) do
        current_user = socket.assigns[:current_user]
        
        ExChessWeb.Presence.subscribe(current_user.id)

        socket
      else
        socket
      end

    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <h3>Actions</h3>

        <.button id="create_game" phx-click="create_game">
          Create Game
        </.button>
       
        <.button id="join_game" phx-click="join_game">
          Join Game
        </.button>
      </div>
    </div>
    """
  end

  def handle_event("create_game", _params, socket) do  
    {:noreply, redirect(socket, to: ~p"/game/#{FriendlyID.generate(3)}")}
  end

  def handle_event("join_game", _params, socket) do  
    {:noreply, socket}
  end

  def handle_info({"navigate", %{game_id: game_id, opponent: opponent}}, socket) do
    socket = 
      if socket.assigns.current_user.id == opponent.id do
        redirect(socket, to: ~p"/game/#{game_id}")
      else
        socket
      end
      
    {:noreply, socket}
  end
end