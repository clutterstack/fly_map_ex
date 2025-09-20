defmodule DemoWeb.PageController do
  use DemoWeb, :controller
  alias DemoWeb.RouteRegistry

  def home(conn, _params), do: render_static_page(conn, "home")
  def about(conn, _params), do: render_static_page(conn, "about")

  defp render_static_page(conn, page_key) do
    route = RouteRegistry.get_route(page_key)

    assigns = %{
      page_title: route.title,
      title: route.title,
      description: Map.get(route, :description, ""),
      keywords: Map.get(route, :keywords, ""),
      nav_order: route.nav_order,
      slug: page_key,
      current_page: page_key,
      flash: conn.assigns[:flash] || %{}
    }

    render(conn, route.controller_action, assigns)
  end
end
