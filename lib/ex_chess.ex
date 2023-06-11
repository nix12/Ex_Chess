defmodule ExChess do
  @moduledoc """
  ExChess keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  def random_string do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64() |> binary_part(0, 8)
  end
end
