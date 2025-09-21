defmodule DemoWeb.PageController do
  @moduledoc """
  Controller for static pages using RouteRegistry metadata.

  This controller handles static pages by extracting metadata from the RouteRegistry
  and passing it to the root layout for SEO meta tag rendering. It implements the
  static page side of the application's SEO metadata system.

  ## SEO Metadata Flow

  1. Route key is used to look up metadata in RouteRegistry
  2. Title, description, and keywords are extracted from route data
  3. Metadata is assigned to connection for root layout access
  4. Root layout conditionally renders meta tags from connection assigns

  For LiveView pages, SEO metadata is handled differently through the
  `get_metadata/0` function pattern in each LiveView module.
  """

  use DemoWeb, :controller
  alias DemoWeb.RouteRegistry

  def home(conn, _params), do: render_static_page(conn, "home")

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
