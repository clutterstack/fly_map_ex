defmodule DemoWeb.RouteRegistry do
  @moduledoc """
  Centralized registry for all application routes and their metadata.

  This module serves as the single source of truth for:
  - Route paths and keys
  - Page titles and navigation order
  - Module mappings for different page types
  - Navigation visibility and organization

  Eliminates duplication across router.ex, content_map.ex, and navigation.ex.
  """

  @routes [
    # Static pages
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
    %{
      path: "/about",
      key: "about",
      type: :static,
      controller_action: :about,
      title: "About FlyMapEx",
      description: "More about the FlyMapEx library and its capabilities.",
      keywords: "about, flymap, elixir, phoenix, documentation",
      nav_order: 2
    },

    # Tutorial content modules (in learning order)
    %{
      path: "/node_placement",
      key: "node_placement",
      type: :content,
      module: DemoWeb.Content.NodePlacement,
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
end