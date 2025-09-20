defmodule DemoWeb.ContentMap do
  require Logger
  alias DemoWeb.RouteRegistry

  @moduledoc """
  Central registry for all pages in the demo application.

  Provides unified title and metadata access for:
  - Content modules (tutorial pages with doc_metadata/0)
  - Standalone LiveViews (registered with titles)
  - Navigation component integration

  ## Usage

      # Get title for any registered page
      DemoWeb.ContentMap.get_page_title("node_placement")
      #=> "Placing markers"

      DemoWeb.ContentMap.get_page_title("demo")
      #=> "Interactive Builder"

      # List all pages for navigation
      DemoWeb.ContentMap.list_all_pages()
      #=> ["node_placement", "marker_styling", "theming", "demo", "machine_map"]

  ## Architecture

  **Content Modules**: Tutorial pages that implement `doc_metadata/0`
  - Registered in RouteRegistry with module references
  - Titles extracted dynamically from module's `doc_metadata().title`
  - Used by PageLive for content-based routes

  **LiveView Modules**: Standalone pages with static titles
  - Registered in RouteRegistry with module references
  - Titles extracted from module's `page_title/0` function
  - Used for navigation without duplicate title maintenance

  This eliminates hardcoded titles in navigation components while providing
  a single source of truth for all page metadata.
  """

  @doc """
  Gets the module for a content page.

  Used by PageLive to resolve content modules.
  Only works for content modules, not LiveView modules.
  """
  def get_page_module(id) do
    case RouteRegistry.get_route(id) do
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

      get_page_title("node_placement")  # => "Placing markers" (from doc_metadata)
      get_page_title("demo")            # => "Interactive Builder" (from page_title)
      get_page_title("unknown_page")    # => "Unknown Page" (humanized fallback)
  """
  def get_page_title(page_id) do
    case RouteRegistry.get_route(page_id) do
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
        Logger.info("Page '#{page_id}' not found in RouteRegistry")
        humanize_page_id(page_id)
    end
  end

  @doc """
  Gets complete metadata for a page.

  For content modules: Returns full doc_metadata/0 result
  For LiveView modules: Returns basic metadata with title
  For unregistered pages: Returns humanized fallback metadata
  """
  def get_page_metadata(page_id) do
    case RouteRegistry.get_route(page_id) do
      %{type: :content, module: module} ->
        try do
          apply(module, :doc_metadata, [])
        rescue
          _ -> %{title: humanize_page_id(page_id), description: "", template: "DefaultTemplate"}
        end

      %{type: :liveview} ->
        %{title: get_page_title(page_id), description: "", template: "LiveView"}

      %{type: :static} ->
        %{title: get_page_title(page_id), description: "", template: "Static"}

      nil ->
        %{title: humanize_page_id(page_id), description: "", template: "Unknown"}
    end
  end

  @doc """
  Lists all content module page IDs.

  Returns page IDs that use content modules with doc_metadata/0.
  """
  def list_content_pages do
    RouteRegistry.keys_for_type(:content)
  end

  @doc """
  Lists all LiveView module page IDs.

  Returns page IDs for standalone LiveViews registered in RouteRegistry.
  """
  def list_liveview_pages do
    RouteRegistry.keys_for_type(:liveview)
  end

  @doc """
  Lists all static page IDs.

  Returns page IDs for static pages handled by PageController.
  """
  def list_static_pages do
    RouteRegistry.keys_for_type(:static)
  end

  @doc """
  Lists all registered page IDs.

  Combines content modules, LiveView modules, and static pages for complete navigation.
  Used by navigation component to build dynamic menu items.
  """
  def list_all_pages do
    RouteRegistry.all_routes()
    |> Enum.map(& &1.key)
  end

  defp humanize_page_id(page_id) do
    page_id
    |> String.replace("_", " ")
    |> String.split()
    |> Enum.map(&String.capitalize/1)
    |> Enum.join(" ")
  end
end
