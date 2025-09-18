defmodule DemoWeb.Router do
  use DemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DemoWeb do
    pipe_through :browser

    get "/", PageController, :home
    get "/about", PageController, :about
    get "/greet", PageController, :show

    # get "/", PageController, :show, page: "home", as: :home_page
    live "/map", MachineMapLive, :index
    live "/live_layout", LiveWithLayout
    live "/demo", MapDemoLive, :index
    live "/stage1", Stage1Live
    live "/stage2", Stage2Live
    live "/stage3", Stage3Live
    live "/stage4", Stage4Live

    # Dynamic liveview pages - must be last to avoid conflicts
    live "/:page_id", PageLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoWeb do
  #   pipe_through :api
  # end
end
