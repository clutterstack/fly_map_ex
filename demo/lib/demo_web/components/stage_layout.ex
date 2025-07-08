defmodule DemoWeb.Components.StageLayout do
  @moduledoc """
  Reusable layout component for stage pages in the FlyMapEx demo.

  This component provides the common structure used across all stage pages,
  including the title section, map display, side-by-side panels, and navigation.
  """

  use Phoenix.Component
  use DemoWeb, :verified_routes

  import DemoWeb.Components.Navigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure
  import DemoWeb.Components.SidebarLayout


  @doc """
  Renders the complete stage layout with all common elements.

  ## Attributes

  - `current_page` - Current page atom for navigation
  - `tabs` - List of tab configurations
  - `current_tab` - Current active tab
  - `title` - Stage title
  - `description` - Stage description
  - `marker_groups` - Current marker groups for map display
  - `current_example` - Current example key
  - `examples` - Map of all examples
  - `advanced_topics` - List of advanced topics for disclosure
  - `navigation` - Navigation configuration with prev/next
  - `get_focused_code` - Function to get focused code
  """
  attr :current_page, :atom, required: true
  attr :tabs, :list, required: true
  attr :current_tab, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :marker_groups, :list, required: true
  attr :current_example, :string, required: true
  attr :examples, :map, required: true
  attr :advanced_topics, :list, required: true
  attr :navigation, :map, required: true
  attr :get_focused_code, :any, required: true

  def stage_layout(assigns) do
    ~H"""
    <!-- Top navigation for mobile/narrow screens -->
    <div class="lg:hidden">
      <.navigation layout={:topbar} current_page={@current_page} />
    </div>
    
    <.sidebar_layout>
      <:sidebar>
        <!-- Sidebar navigation for wide screens -->
        <div class="hidden lg:block h-full">
          <.navigation layout={:sidebar} current_page={@current_page} tabs={@tabs} current_tab={@current_tab} />
        </div>
      </:sidebar>

      <:main>
        <div class="container mx-auto p-8">

          <.stage_map marker_groups={@marker_groups} />

          <.stage_content_panels
            tabs={@tabs}
            current_tab={@current_tab}
            current_example={@current_example}
            current_example_description={@current_example_description}
            marker_groups={@marker_groups}
            get_focused_code={@get_focused_code}
          />

          <.stage_advanced_topics topics={@advanced_topics} />

          <.stage_navigation navigation={@navigation} />
        </div>
      </:main>
    </.sidebar_layout>
    """
  end

  @doc """
  Renders the stage header with title and description.
  """
  attr :title, :string, required: true
  attr :description, :string, required: true

  def stage_header(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex justify-between items-center mb-4">
        <h1 class="text-3xl font-bold text-base-content"><%= @title %></h1>
      </div>
      <p class="text-base-content/70 mb-6">
        <%= @description %>
      </p>
    </div>
    """
  end

  @doc """
  Renders the full-width map display.
  """
  attr :marker_groups, :list, required: true

  def stage_map(assigns) do
    ~H"""
    <div class="mb-8 p-6 bg-base-200 rounded-lg">
      <FlyMapEx.render
        marker_groups={@marker_groups}
        layout={:side_by_side}
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
  attr :marker_groups, :list, required: true
  attr :get_focused_code, :any, required: true

  def stage_content_panels(assigns) do
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
          marker_groups={@marker_groups}
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
  attr :marker_groups, :list, required: true
  attr :get_focused_code, :any, required: true

  def code_examples_panel(assigns) do
    ~H"""
    <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
    <!-- Quick Stats -->
      <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
        <div class="text-sm text-primary">
          <%= @current_example_description %> •
          <%= if @marker_groups, do: length(@marker_groups), else: 0 %> groups •
          <%= count_total_nodes(@marker_groups) %> nodes
        </div>
      </div>
      <div class="p-4">
        <pre class="text-sm text-base-content overflow-x-auto bg-base-200 p-3 rounded"><code><%= @get_focused_code.(@current_example, @marker_groups) %></code></pre>
      </div>


    </div>
    """
  end

  @doc """
  Renders the advanced topics section.
  """
  attr :topics, :list, required: true

  def stage_advanced_topics(assigns) do
    ~H"""
    <.learn_more_section topics={@topics} />
    """
  end

  @doc """
  Renders the stage navigation with prev/next buttons.
  """
  attr :navigation, :map, required: true

  def stage_navigation(assigns) do
    ~H"""
    <div class="mt-8 flex justify-between">
      <%= if @navigation.prev do %>
        <.link navigate={~p"/#{@navigation.prev}"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
          <%= get_prev_label(@navigation.prev) %>
        </.link>
      <% else %>
        <.link navigate={~p"/"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
          ← Back to Home
        </.link>
      <% end %>

      <%= if @navigation.next do %>
        <.link navigate={~p"/#{@navigation.next}"} class="inline-block bg-primary text-primary-content px-6 py-2 rounded-lg hover:bg-primary/80 transition-colors">
          <%= get_next_label(@navigation.next) %>
        </.link>
      <% else %>
        <div></div>
      <% end %>
    </div>
    """
  end

  # Helper functions

  defp count_total_nodes(marker_groups) when is_nil(marker_groups), do: 0
  defp count_total_nodes(marker_groups) do
    Enum.reduce(marker_groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp get_prev_label(stage) do
    case stage do
      :stage1 -> "← Stage 1: Defining Marker Groups"
      :stage2 -> "← Stage 2: Styling Markers"
      :stage3 -> "← Stage 3: Map Themes"
      :stage4 -> "← Stage 4: Advanced Features"
      _ -> "← Previous"
    end
  end

  defp get_next_label(stage) do
    case stage do
      :stage1 -> "Next: Stage 1 - Defining Marker Groups →"
      :stage2 -> "Next: Stage 2 - Styling Markers →"
      :stage3 -> "Next: Stage 3 - Map Themes →"
      :stage4 -> "Next: Stage 4 - Advanced Features →"
      _ -> "Next →"
    end
  end
end
