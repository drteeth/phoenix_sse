defmodule PhoenixSseWeb.Router do
  use PhoenixSseWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :sse do
    plug :accepts, ["sse"]
  end

  scope "/", PhoenixSseWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/", PhoenixSseWeb do
    pipe_through :sse

    get "/sse", PageController, :sse
  end
end
