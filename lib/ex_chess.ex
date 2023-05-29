defmodule ExChess do
  @moduledoc """
  ExChess keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  # Example for searching empty squares:
  # alpha_binary = for x <- 0..7 do
  #   if sel_alpha == @alpha_list |> Enum.at(x) do
  #     96 + x + 1
  #   end
  # end |> Enum.find(fn x -> x != nil end )

  def random_string do
    :crypto.strong_rand_bytes(8) |> Base.url_encode64() |> binary_part(0, 8)
  end
end
