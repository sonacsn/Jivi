defmodule JiviWeb.PageController do
  use JiviWeb, :controller

  def index(conn, _params) do
    IO.puts "in index p contr"
    #IO.inspect _params
    render conn, "index.html"
  end
  def game(conn, params) do
    render conn, "game.html", game: params["game"], player: params["player"]
  end
end
