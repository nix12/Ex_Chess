defmodule ExChess.Core.Query.ParticipantsQuery do
	import Ecto.Query, only: [from: 2]

	alias ExChess.Accounts.User

	@doc"""
	Search for an opponent from the database where the status is online
	"""
  def opponent_search_query(current_user) do
    from(
      u in User,
      where: u.status == :online and u.id != ^current_user.id,
      select: %{id: u.id, username: u.username, email: u.email, status: u.status},
      order_by: fragment("RANDOM()"),
      limit: 1
    )
  end
end