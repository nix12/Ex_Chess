defmodule ExChess.Factory do
    # with Ecto
    use ExMachina.Ecto, repo: ExChess.Repo

    def chessboard_factory do
      %ExChess.Core.Schema.Chessboard{
        board: for(x <- 1..8, y <- 1..8, into: %{}, do: {[y, x], nil}), 
        prev_board: nil
      }
    end

    def game_factory do
      ExChess.Core.Schema.Game{
        current_turn: nil,
        winner: nil,
        chessboard: build(:chessboard),
        participants: build(:participants),
      }
    end

    def participants_factory do
      ExChess.Core.Schema.Participants{
        player_color: ,
        opponent_color: ,
        in_check?: false,
        checkmate?: false,
        game: build(:game),
        player: build(:user),
        opponent: build(:user)
      }
    end
  
    def user_factory do
      %ExChess.User{
        name: "Jane Smith",
        email: sequence(:email, &"email-#{&1}@example.com"),
        role: sequence(:role, ["admin", "user", "other"]),
      }
    end
  
    def article_factory do
      title = sequence(:title, &"Use ExMachina! (Part #{&1})")
      # derived attribute
      slug = ExChess.Article.title_to_slug(title)
      %ExChess.Article{
        title: title,
        slug: slug,
        # another way to build derived attributes
        tags: fn article ->
          if String.contains?(article.title, "Silly") do
            ["silly"]
          else
            []
          end
        end,
        # associations are inserted when you call `insert`
        author: build(:user)
      }
    end
  
    # derived factory
    def featured_article_factory do
      struct!(
        article_factory(),
        %{
          featured: true,
        }
      )
    end
  
    def comment_factory do
      %ExChess.Comment{
        text: "It's great!",
        article: build(:article),
      }
    end
  end