defmodule JiviWeb.PageController do
  use JiviWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
  def game(conn, params) do
    IO.inspect params
    render conn, "game.html", game: params["game"], player: params["player"]
  end
end
