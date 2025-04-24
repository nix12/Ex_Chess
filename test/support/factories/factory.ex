defmodule ExChess.Factory do
    # with Ecto
    use ExMachina.Ecto, repo: ExChess.Repo

    def chessboard_factory do
      %ExChess.Core.Schema.Chessboard{board: , prev_board: nil}
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