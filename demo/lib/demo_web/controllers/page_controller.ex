defmodule DemoWeb.PageController do
  use DemoWeb, :controller

  alias DemoWeb.Helpers.PageDiscovery

  def show(conn, _params) do
    base_assigns = %{messenger: "flooo"}
    render(conn, :show, base_assigns)
  end

  def home(conn, _params) do
    home_assigns = %{
      title: "FlyMapEx Demo Home",
      description:
        "This demo showcases FlyMapEx, a Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.",
      nav_order: 0,
      keywords: "elixir, phoenix, maps, fly.io, interactive, world map",
      slug: "home",
      current_page: :home,
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
      current_page: :about,
      flash: conn.assigns[:flash] || %{}
    }

    render(conn, :about, about_assigns)
  end

  def showp(conn, params) do
    slug = params["page"] || conn.path_params["page"] || "home"

    case PageDiscovery.get_page(slug) do
      nil ->
        conn
        |> put_status(:not_found)
        |> put_view(DemoWeb.ErrorHTML)
        |> render(:"404")

      page ->
        # Build assigns for the page
        base_assigns = %{
          page_title: page.title,
          page_description: page.description,
          page_slug: page.slug,
          seo_keywords: page.keywords,
          flash: conn.assigns[:flash] || %{}
        }

        # Generate content
        content = page.module.content(base_assigns)
        content_assigns = Map.put(base_assigns, :page_content, content)

        render(conn, :show, content_assigns)
    end
  end
end
