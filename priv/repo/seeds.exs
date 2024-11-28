# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     ExChess.Repo.insert!(%ExChess.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias ExChess.Repo
alias ExChess.Accounts.Schema.User

Repo.insert_all(User, [
  %{username: "first", email: "first@email.com", password: "password"},
  %{username: "second", email: "second@email.com", password: "password"},
  %{username: "third", email: "third@email.com", password: "password"},
  %{username: "fourth", email: "fourth@email.com", password: "password"},
  %{username: "fifth", email: "fifth@email.com", password: "password"},
  %{username: "sixth", email: "sixth@email.com", password: "password"},
  %{username: "seventh", email: "seventh@email.com", password: "password"},
  %{username: "eigth", email: "eigth@email.com", password: "password"},
  %{username: "nineth", email: "nineth@email.com", password: "password"},
  %{username: "tenth", email: "tenth@email.com", password: "password"}
])
