defmodule DemoWeb.Controllers.PageBase do
  @moduledoc """
  Behaviour for creating standardized page controllers with common patterns.

  This behaviour defines the structure and callbacks needed for page components
  in the FlyMapEx demo application, providing a consistent interface for
  authoring new pages while supporting both static content and interactive maps.

  ## Examples

      defmodule DemoWeb.MyPageController do
        use DemoWeb.Controllers.PageBase

        def page_title, do: "My Custom Page"
        def page_description, do: "A page with map integration"
        def page_slug, do: "my-page"
        
        def page_content(_assigns) do
          ~H'''
          <p>Custom content with marker groups: {@marker_groups}</p>
          '''
        end
        
        def marker_groups do
          [%{nodes: ["fra", "sjc"], label: "Example"}]
        end
      end
  """

  # Required callbacks for page-specific content
  @callback page_title() :: String.t()
  @callback page_description() :: String.t()
  @callback page_slug() :: String.t()

  # Optional callbacks with default implementations
  @callback page_content(map()) :: Phoenix.LiveView.Rendered.t()
  @callback marker_groups() :: list(map()) | nil
  @callback nav_order() :: integer() | nil
  @callback page_theme() :: atom()
  @callback page_layout() :: atom()
  @callback seo_keywords() :: String.t() | nil
  @callback sidebar_content(map()) :: Phoenix.LiveView.Rendered.t() | nil

  @optional_callbacks [
    page_content: 1,
    marker_groups: 0,
    nav_order: 0,
    page_theme: 0,
    page_layout: 0,
    seo_keywords: 0,
    sidebar_content: 1
  ]

  defmacro __using__(_opts) do
    quote do
      @behaviour DemoWeb.Controllers.PageBase

      use DemoWeb, :controller

      def show(conn, _params) do
        marker_groups = get_marker_groups()
        
        base_assigns = %{
          page_title: page_title(),
          page_description: page_description(),
          page_slug: page_slug(),
          marker_groups: marker_groups,
          page_theme: get_page_theme(),
          page_layout: get_page_layout(),
          seo_keywords: get_seo_keywords(),
          flash: conn.assigns[:flash] || %{}
        }

        content_assigns = Map.merge(base_assigns, %{page_content: page_content(base_assigns)})

        render(conn, :show, content_assigns)
      end

      # Helper functions with defaults
      defp get_marker_groups do
        if function_exported?(__MODULE__, :marker_groups, 0) do
          apply(__MODULE__, :marker_groups, [])
        else
          nil
        end
      end

      defp get_page_theme do
        if function_exported?(__MODULE__, :page_theme, 0) do
          apply(__MODULE__, :page_theme, [])
        else
          :responsive
        end
      end

      defp get_page_layout do
        if function_exported?(__MODULE__, :page_layout, 0) do
          apply(__MODULE__, :page_layout, [])
        else
          :default
        end
      end

      defp get_seo_keywords do
        if function_exported?(__MODULE__, :seo_keywords, 0) do
          apply(__MODULE__, :seo_keywords, [])
        else
          nil
        end
      end

      defp get_nav_order do
        if function_exported?(__MODULE__, :nav_order, 0) do
          apply(__MODULE__, :nav_order, [])
        else
          nil
        end
      end

      # Default page content if not overridden
      def page_content(assigns) do
        content = """
        <div class="prose prose-lg max-w-none">
          <p>Default page content. Override the <code>page_content/1</code> callback to customize.</p>
        </div>
        """
        Phoenix.HTML.raw(content)
      end

      # Default sidebar content
      def sidebar_content(_assigns), do: nil

      # Make these overridable
      defoverridable [page_content: 1, sidebar_content: 1]

      # Register this page module for discovery
      def __page_info__ do
        %{
          title: page_title(),
          description: page_description(),
          slug: page_slug(),
          nav_order: get_nav_order(),
          module: __MODULE__,
          type: :behaviour
        }
      end
    end
  end

  @doc """
  Returns all registered page behaviour modules.
  """
  def discover_behaviour_pages do
    :code.all_loaded()
    |> Enum.filter(fn {module, _} ->
      Code.ensure_loaded(module)
      function_exported?(module, :__page_info__, 0)
    end)
    |> Enum.map(fn {module, _} -> module.__page_info__() end)
    |> Enum.sort_by(fn page -> {page.nav_order || 999, page.title} end)
  end
end