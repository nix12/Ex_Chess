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
alias ExChess.Accounts

Accounts.register_user(%{username: "first", email: "first@email.com", password: "password"})
Accounts.register_user(%{username: "second", email: "second@email.com", password: "password"})
Accounts.register_user(%{username: "third", email: "third@email.com", password: "password"})
Accounts.register_user(%{username: "fourth", email: "fourth@email.com", password: "password"})
Accounts.register_user(%{username: "fifth", email: "fifth@email.com", password: "password"})
Accounts.register_user(%{username: "sixth", email: "sixth@email.com", password: "password"})
Accounts.register_user(%{username: "seventh", email: "seventh@email.com", password: "password"})
Accounts.register_user(%{username: "eighth", email: "eighth@email.com", password: "password"})
Accounts.register_user(%{username: "nineth", email: "nineth@email.com", password: "password"})
Accounts.register_user(%{username: "tenth", email: "tenth@email.com", password: "password"})
