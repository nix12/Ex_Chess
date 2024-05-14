defmodule ExChessWeb.LobbyLive do
  @moduledoc """
  Handles initial connection to application
  """
  use ExChessWeb, :live_view

  alias ExChess.Core

  def mount(_params, _session, socket) do    
    socket =
      if connected?(socket) do
        current_user = socket.assigns[:current_user]
        
        tracking_params = %{
          id: current_user.email,
          username: current_user.username, 
          status: current_user.status
        }
        
        ExChessWeb.Presence.track_user(current_user.email, tracking_params)
        ExChessWeb.Presence.subscribe()

        socket
        |> stream(:presences, ExChessWeb.Presence.list_online_users())
        |> assign(online_players: get_online_player_count(current_user))

      else
        socket
        |> stream(:presences, [])
        |> assign(online_players: 0)
      end

    {:ok, socket}
  end
  
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <h3>Online Users (<%= @online_players %>)</h3>

        <ul id="online_users" phx-update="stream">
          <li 
            :for={{dom_id, %{metas: metas}} <- @streams.presences} 
            id={dom_id}
          >
            <%= metas |> Enum.at(0) |> Map.get(:username) %>
          </li>
        </ul>
      </div>

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
    {:noreply, redirect(socket, to: ~p"/game/#{generate_game_id()}")}
  end

  def handle_event("join_game", _params, socket) do  
    {:noreply, socket}
  end

  def handle_info({ExChessWeb.Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({ExChessWeb.Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff"} = _event, socket) do
    online_players = get_online_player_count(socket.assigns.current_user)

    {:noreply, assign(socket, online_players: online_players)}
  end

  def handle_info({"navigate", %{players: [_player, opponent], game_id: game_id}}, socket) do
    socket = 
      if socket.assigns.current_user.id == opponent.id do
        redirect(socket, to: ~p"/game/#{game_id}")
      else
        socket
      end
      
    {:noreply, socket}
  end

  defp get_online_player_count(%{email: email}) do
    case ExChessWeb.Presence.list("*") do
      %{^email => %{metas: list}} -> 
        Enum.count(list)
        
      _ -> 
        0
    end
  end

  defp generate_game_id() do
    length = 12

    :crypto.strong_rand_bytes(length) |> Base.encode64 |> binary_part(0, length)
  end
end