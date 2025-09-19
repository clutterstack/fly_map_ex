defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  def home(conn, _params) do
    home_assigns = %{
      title: "FlyMapEx Demo Home",
      description:
        "This demo showcases FlyMapEx, a Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.",
      nav_order: 0,
      keywords: "elixir, phoenix, maps, fly.io, interactive, world map",
      slug: "home",
      current_page: "home",
      flash: conn.assigns[:flash] || %{}
    }

    render(conn, :home, home_assigns)
  end

  def about(conn, _params) do
    about_assigns = %{
      title: "About FlyMapEx",
      description: "More about the FlyMapEx library and its capabilities.",
      nav_order: 1,
      keywords: "about, flymap, elixir, phoenix, documentation",
      slug: "about",
      current_page: "about",
      flash: conn.assigns[:flash] || %{}
    }

    render(conn, :about, about_assigns)
  end

end
