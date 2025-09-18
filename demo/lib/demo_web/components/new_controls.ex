defmodule DemoWeb.Components.NewControls do
  @moduledoc """
  Reusable interactive control components for the FlyMapEx demo stages.

  Provides consistent button styling and interaction patterns across all stages.
  """

  use Phoenix.Component

  @doc """
  Renders the code examples panel with stats.
  """
  # attr :current_example, :string, required: true
  # attr :current_example_description, :string, required: true
  # attr :marker_groups, :list, required: true
  # attr :get_focused_code, :any, required: true

  # def new_code_examples_panel(assigns) do
  #   ~H"""
  #   <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
  #     <!-- Quick Stats -->
  #     <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
  #       <div class="text-sm text-primary">
  #         {@current_example_description} • {if @marker_groups, do: length(@marker_groups), else: 0} groups • {count_total_nodes(
  #           @marker_groups
  #         )} nodes
  #       </div>
  #     </div>
  #     <div class="p-4">
  #       <pre class="text-sm text-base-content whitespace-pre-wrap overflow-x-auto bg-base-200 p-3 rounded"><code><%= @get_focused_code.(@current_example, @marker_groups) %></code></pre>
  #     </div>
  #   </div>
  #   """
  # end


    @doc """
  Renders a tabbed info panel that combines navigation and content.

  ## Attributes
  * `tabs` - List of tab maps with :key, :label, :content
  * `current_tab` - Current active tab index
  * `event` - Phoenix event name to trigger on tab click
  * `show_tabs` - Whether to show the tab navigation (default: true)
  * `class` - Additional CSS classes
  """

  def new_tabbed_info_panel(assigns) do
  ~H"""
  <div class={["bg-base-100 border border-base-300 rounded-lg overflow-hidden", @class]}>
    <!-- Tab Navigation -->
    <%= if @show_tabs do %>
      <div class="border-b border-base-300 bg-base-200">
        <nav class="flex space-x-1 p-1">
          <%= for {tab, idx} <- Enum.with_index(@tabs) do %>
            <button
              phx-click="switch_tab"
              phx-value-index={idx}
              phx-target={@click_target}
              class={[
                "px-3 py-2 text-sm font-medium rounded-md transition-all duration-200",
                "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-inset",
                get_tab_classes(idx == @current_tab)
              ]}
            >
              {tab.label}
            </button>
          <% end %>
        </nav>
      </div>
    <% end %>

    <!-- Tab Content -->
    <div class="p-4">

      {Phoenix.HTML.raw(@tab_content)}

    </div>
  </div>
  """
end

  defp get_tab_classes(true) do
    [
      "bg-base-100 text-primary shadow-sm border-primary/20",
      "border-t border-l border-r"
    ]
  end

  defp get_tab_classes(false) do
    [
      "text-base-content/70 hover:text-base-content/80 hover:bg-base-200",
      "border-transparent"
    ]
  end
end
