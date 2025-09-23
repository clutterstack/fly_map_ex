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

  def home(conn, _params) do
    assigns = %{
      page_title: "FlyMapEx Demo",
      title: "FlyMapEx Demo",
      description: "A demo site for FlyMapEx, a Phoenix LiveView library for displaying markers on a simple world map.",
      keywords: "elixir, phoenix, maps, fly.io, interactive, world map",
      current_page: "home",
      flash: conn.assigns[:flash] || %{}
    }

    render(conn, :home, assigns)
  end

end
