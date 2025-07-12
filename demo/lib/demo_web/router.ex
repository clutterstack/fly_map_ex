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

    get "/", HomePageController, :show
    live "/map", MachineMapLive, :index
    live "/demo", MapDemoLive, :index
    live "/stage1", Stage1Live
    live "/stage2", Stage2Live
    live "/stage3", Stage3Live
    live "/stage4", Stage4Live
    
    # Dynamic static pages - must be last to avoid conflicts
    get "/:page", PageController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", DemoWeb do
  #   pipe_through :api
  # end
end
