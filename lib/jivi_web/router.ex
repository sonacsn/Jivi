defmodule JiviWeb.Router do
  use JiviWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", JiviWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    # get "/game/:game", PageController, :game
    IO.puts "in page controller"
    get "/game/:game/player/:player", PageController, :game
  end

  # Other scopes may use custom stacks.
  # scope "/api", JiviWeb do
  #   pipe_through :api
  # end
end
