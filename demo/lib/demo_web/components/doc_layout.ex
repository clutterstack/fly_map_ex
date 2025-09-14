defmodule DemoWeb.Components.DocLayout do
  @moduledoc """
  Reusable layout component for documentation pages in the generic tutorial system.

  This component provides the common structure used across all documentation pages,
  including the title section, interactive component display, side-by-side panels,
  and navigation. Generalized from StageLayout to support multiple component types.
  """

  use Phoenix.Component
  use DemoWeb, :verified_routes

  import DemoWeb.Components.Navigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.SidebarLayout
  import DemoWeb.Helpers.DocComponentRegistry

  @doc """
  Renders the complete documentation layout with all common elements.

  ## Attributes

  - `current_page` - Current page atom for navigation
  - `tabs` - List of tab configurations
  - `current_tab` - Current active tab
  - `title` - Documentation title
  - `description` - Documentation description
  - `component_type` - Type of interactive component (:map, :chart, etc.)
  - `examples` - Current examples for component display
  - `current_example` - Current example key
  - `all_examples` - Map of all examples
  - `navigation` - Navigation configuration with prev/next
  - `get_focused_code` - Function to get focused code
  """
  attr :current_page, :atom, required: true
  attr :tabs, :list, required: true
  attr :current_tab, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :component_type, :atom, required: true
  attr :examples, :any, required: true
  attr :current_example, :string, required: true
  attr :all_examples, :map, required: true
  attr :navigation, :map, required: true
  attr :get_focused_code, :any, required: true
  attr :layout, :atom, default: :side_by_side
  attr :theme, :any, default: nil

  def doc_layout(assigns) do
    ~H"""
    <!-- Top navigation for mobile/narrow screens -->
    <div class="lg:hidden">
      <.navigation layout={:topbar} current_page={@current_page} />
    </div>

    <.sidebar_layout>
      <:sidebar>
        <!-- Sidebar navigation for wide screens -->
        <div class="hidden lg:block h-full">
          <.navigation
            layout={:sidebar}
            current_page={@current_page}
            tabs={@tabs}
            current_tab={@current_tab}
          />
        </div>
      </:sidebar>

      <:main>
        <div class="w-full p-8">
          <.doc_component
            component_type={@component_type}
            examples={@examples}
            layout={@layout}
            theme={@theme}
          />

          <.doc_content_panels
            tabs={@tabs}
            current_tab={@current_tab}
            current_example={@current_example}
            current_example_description={@current_example_description}
            examples={@examples}
            get_focused_code={@get_focused_code}
          />

          <.doc_navigation navigation={@navigation} />
        </div>
      </:main>
    </.sidebar_layout>
    """
  end

  @doc """
  Renders the documentation header with title and description.
  """
  attr :title, :string, required: true
  attr :description, :string, required: true

  def doc_header(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-3xl font-bold text-base-content">{@title}</h1>
      </div>
      <p class="text-base-content/70 mb-6">
        {@description}
      </p>
    </div>
    """
  end

  @doc """
  Renders the interactive component display using the component registry.
  """
  attr :component_type, :atom, required: true
  attr :examples, :any, required: true
  attr :layout, :atom, default: :side_by_side
  attr :theme, :any, default: nil

  def doc_component(assigns) do
    ~H"""
    <div class="mb-8 p-6 bg-base-200 rounded-lg">
      <.render_component
        component_type={@component_type}
        examples={@examples}
        opts={%{layout: @layout, theme: @theme}}
      />
    </div>
    """
  end

  @doc """
  Renders the side-by-side content panels with tabbed info and code examples.
  """
  attr :tabs, :list, required: true
  attr :current_tab, :string, required: true
  attr :current_example, :string, required: true
  attr :current_example_description, :string, required: true
  attr :examples, :any, required: true
  attr :get_focused_code, :any, required: true

  def doc_content_panels(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
      <!-- Tabbed Info Panel -->
      <div>
        <.tabbed_info_panel
          tabs={@tabs}
          current={@current_tab}
          event="switch_example"
          show_tabs={false}
        />
      </div>

      <!-- Code Examples Panel -->
      <div>
        <.code_examples_panel
          current_example={@current_example}
          current_example_description={@current_example_description}
          examples={@examples}
          get_focused_code={@get_focused_code}
        />
      </div>
    </div>
    """
  end

  @doc """
  Renders the code examples panel with stats.
  """
  attr :current_example, :string, required: true
  attr :current_example_description, :string, required: true
  attr :examples, :any, required: true
  attr :get_focused_code, :any, required: true

  def code_examples_panel(assigns) do
    ~H"""
    <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
      <!-- Quick Stats -->
      <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
        <div class="text-sm text-primary">
          {@current_example_description} • {if @examples, do: get_examples_count(@examples), else: 0} groups • {count_total_nodes(
            @examples
          )} nodes
        </div>
      </div>
      <div class="p-4">
        <pre class="text-sm text-base-content whitespace-pre-wrap overflow-x-auto bg-base-200 p-3 rounded"><code><%= @get_focused_code.(@current_example, @examples) %></code></pre>
      </div>
    </div>
    """
  end

  @doc """
  Renders the documentation navigation with prev/next buttons.
  """
  attr :navigation, :map, required: true

  def doc_navigation(assigns) do
    ~H"""
    <div class="mt-8 flex justify-between">
      <%= if @navigation.prev do %>
        <.link
          navigate={~p"/#{@navigation.prev}"}
          class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors"
        >
          {get_prev_label(@navigation.prev)}
        </.link>
      <% else %>
        <.link
          navigate={~p"/"}
          class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors"
        >
          ← Back to Home
        </.link>
      <% end %>

      <%= if @navigation.next do %>
        <.link
          navigate={~p"/#{@navigation.next}"}
          class="inline-block bg-primary text-primary-content px-6 py-2 rounded-lg hover:bg-primary/80 transition-colors"
        >
          {get_next_label(@navigation.next)}
        </.link>
      <% else %>
        <div></div>
      <% end %>
    </div>
    """
  end

  # Helper functions

  defp get_examples_count(examples) when is_nil(examples), do: 0
  defp get_examples_count(examples) when is_list(examples), do: length(examples)
  defp get_examples_count(_), do: 1

  defp count_total_nodes(examples) when is_nil(examples), do: 0

  defp count_total_nodes(examples) when is_list(examples) do
    Enum.reduce(examples, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp count_total_nodes(_), do: 0

  defp get_prev_label(stage) do
    case stage do
      :stage1 -> "← Placing Markers"
      :stage2 -> "← Marker Styles"
      :stage3 -> "← Map Themes"
      :stage4 -> "← Advanced Features"
      _ -> "← Previous"
    end
  end

  defp get_next_label(stage) do
    case stage do
      :stage1 -> "Next: Placing Markers →"
      :stage2 -> "Next: Marker Styles →"
      :stage3 -> "Map Themes →"
      :stage4 -> "Next: Advanced Features →"
      _ -> "Next →"
    end
  end
end