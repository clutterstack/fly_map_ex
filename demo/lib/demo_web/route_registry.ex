defmodule DemoWeb.RouteRegistry do
  @moduledoc """
  Centralized registry for all application routes and their metadata.

  This module serves as the single source of truth for:
  - Route paths and keys
  - Page titles and navigation order
  - Module mappings for different page types
  - Navigation visibility and organization
  - SEO metadata for static pages

  Eliminates duplication across router.ex, content_map.ex, and navigation.ex.

  ## SEO Metadata System

  For static pages (type `:static`), this registry provides SEO metadata including
  title, description, and keywords. The PageController extracts this metadata and
  passes it to the root layout for rendering as meta tags.

  LiveView pages (type `:liveview`) handle their own SEO metadata through the
  standardized `get_metadata/0` function pattern implemented in each LiveView module.

  ## Route Structure

  Each route entry contains:
  - `path` - URL path for the route
  - `key` - Unique identifier for the route
  - `type` - Route type (`:static`, `:liveview`, `:content`)
  - `title` - Page title for SEO and navigation
  - `description` - Page description for search engines (static pages only)
  - `keywords` - Comma-separated keywords for search indexing (static pages only)
  - `nav_order` - Position in navigation menu
  - Additional type-specific fields
  """

  @routes [
    # Static pages
    # PageController uses some of this.
    %{
      path: "/",
      key: "home",
      type: :static,
      controller_action: :home,
      title: "FlyMapEx Demo Home",
      description: "This demo showcases FlyMapEx, a Phoenix LiveView library for displaying interactive world maps with Fly.io region markers.",
      keywords: "elixir, phoenix, maps, fly.io, interactive, world map",
      nav_order: 1
    },
    # Tutorial content modules (in learning order)
    %{
      path: "/basic_use",
      key: "basic_use",
      type: :content,
      module: DemoWeb.Content.BasicUsage,
      nav_order: 3
    },
    %{
      path: "/marker_styling",
      key: "marker_styling",
      type: :content,
      module: DemoWeb.Content.MarkerStyling,
      nav_order: 4
    },
    %{
      path: "/theming",
      key: "theming",
      type: :content,
      module: DemoWeb.Content.Theming,
      nav_order: 5
    },

    # Interactive tools
    %{
      path: "/demo",
      key: "demo",
      type: :liveview,
      module: DemoWeb.MapDemoLive,
      nav_order: 6
    },
    %{
      path: "/my_machines",
      key: "my_machines",
      type: :liveview,
      module: DemoWeb.MachineMapLive,
      nav_order: 7
    },

    # Development/testing pages
    %{
      path: "/live_with_layout",
      key: "live_with_layout",
      type: :liveview,
      module: DemoWeb.LiveWithLayout,
      nav_order: 8
    }
  ]

  @doc """
  Returns all registered routes.
  """
  def all_routes, do: @routes

  @doc """
  Returns routes in navigation order for menu display.
  """
  def navigation_routes do
    @routes
    |> Enum.sort_by(& &1.nav_order)
  end

  @doc """
  Gets a specific route by its key.
  """
  def get_route(key) do
    Enum.find(@routes, & &1.key == key)
  end

  @doc """
  Returns only content module routes.
  """
  def content_routes do
    Enum.filter(@routes, & &1.type == :content)
  end

  @doc """
  Returns only LiveView routes.
  """
  def liveview_routes do
    Enum.filter(@routes, & &1.type == :liveview)
  end

  @doc """
  Returns only static page routes.
  """
  def static_routes do
    Enum.filter(@routes, & &1.type == :static)
  end

  @doc """
  Gets all route keys for a specific type.
  """
  def keys_for_type(type) do
    @routes
    |> Enum.filter(& &1.type == type)
    |> Enum.map(& &1.key)
  end

  @doc """
  Checks if a route key is registered.
  """
  def route_exists?(key) do
    get_route(key) != nil
  end

  @doc """
  Gets the module for a content page.

  Used by PageLive to resolve content modules.
  Only works for content modules, not LiveView modules.
  """
  def get_route_module(id) do
    case get_route(id) do
      %{type: :content, module: module} -> module
      _ -> raise ArgumentError, "Page '#{id}' is not a content module"
    end
  end

  @doc """
  Gets the display title for any registered page.

  For content modules: Extracts title from doc_metadata/0
  For LiveView modules: Extracts title from page_title/0
  For static pages: Returns stored title from RouteRegistry
  For unregistered pages: Returns humanized page ID

  ## Examples

      get_route_title("basic_use")  # => "Basic use" (from doc_metadata)
      get_route_title("demo")       # => "Interactive Builder" (from page_title)
      get_route_title("unknown_page") # => "Unknown Page" (humanized fallback)
  """
  def get_route_title(page_id) do
    case get_route(page_id) do
      %{type: :content, module: module} ->
        try do
          %{title: title} = apply(module, :doc_metadata, [])
          title
        rescue
          _ -> humanize_page_id(page_id)
        end

      %{type: :liveview, module: module} ->
        try do
          apply(module, :page_title, [])
        rescue
          _ -> humanize_page_id(page_id)
        end

      %{type: :static, title: title} ->
        title

      nil ->
        require Logger
        Logger.info("Page '#{page_id}' not found in RouteRegistry")
        humanize_page_id(page_id)
    end
  end

  defp humanize_page_id(page_id) do
    page_id
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
