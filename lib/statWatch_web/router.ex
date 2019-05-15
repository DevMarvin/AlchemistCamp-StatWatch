defmodule StatWatchWeb.Router do
  use StatWatchWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug StatWatch.Auth, repo: StatWatch.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", StatWatchWeb do
    pipe_through :browser

    get "/", PageController, :index
    resources "/users", UserController
    resources "/profiles", ProfileController

    post "/login", SessionController, :create
    get "/login", SessionController, :new
    get "/logout", SessionController, :delete
  end

  # Other scopes may use custom stacks.
  # scope "/api", StatWatchWeb do
  #   pipe_through :api
  # end
end
