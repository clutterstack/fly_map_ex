defmodule DemoWeb.Components.InteractiveControls do
  @moduledoc """
  Reusable interactive control components for the FlyMapEx demo stages.

  Provides consistent button styling and interaction patterns across all stages.
  """

  use Phoenix.Component

  @doc """
  Renders a set of preset buttons for switching between different configurations.

  ## Attributes
  * `options` - List of option maps with :key, :label, and optional :description
  * `current` - Current active option key
  * `event` - Phoenix event name to trigger on click
  * `class` - Additional CSS classes for the container
  """
  attr :options, :list, required: true
  attr :current, :any, required: true
  attr :event, :string, required: true
  attr :class, :string, default: ""

  def preset_buttons(assigns) do
    ~H"""
    <div class={["flex flex-wrap gap-3", @class]}>
      <%= for option <- @options do %>
        <button
          phx-click={@event}
          phx-value-option={option.key}
          class={[
            "px-4 py-2 rounded-lg font-medium transition-all duration-200",
            "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2",
            get_button_classes(option.key == @current)
          ]}
          title={option[:description]}
        >
          {option.label}
        </button>
      <% end %>
    </div>
    """
  end

  @doc """
  Renders a toggle button that switches between two states.

  ## Attributes
  * `active` - Boolean indicating if the toggle is active
  * `event` - Phoenix event name to trigger on click
  * `active_label` - Label to show when active
  * `inactive_label` - Label to show when inactive
  * `active_color` - Color scheme when active (default: "blue")
  * `class` - Additional CSS classes
  """
  attr :active, :boolean, required: true
  attr :event, :string, required: true
  attr :active_label, :string, required: true
  attr :inactive_label, :string, required: true
  attr :active_color, :string, default: "blue"
  attr :class, :string, default: ""

  def toggle_button(assigns) do
    ~H"""
    <button
      phx-click={@event}
      class={[
        "px-4 py-2 rounded-lg font-medium transition-all duration-200",
        "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-offset-2",
        get_toggle_classes(@active, @active_color),
        @class
      ]}
    >
      {if @active, do: @active_label, else: @inactive_label}
    </button>
    """
  end

  @doc """
  Renders an information panel with key concepts or current state.

  ## Attributes
  * `title` - Panel title
  * `color` - Color scheme (default: "blue")
  * `class` - Additional CSS classes
  """
  attr :title, :string, required: true
  attr :color, :string, default: "blue"
  attr :class, :string, default: ""

  slot :inner_block, required: true

  def info_panel(assigns) do
    ~H"""
    <div class={[
      "border rounded-lg p-4",
      get_panel_classes(@color),
      @class
    ]}>
      <h3 class={["font-semibold mb-2", get_title_classes(@color)]}>
        {@title}
      </h3>
      <div class={get_content_classes(@color)}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  @doc """
  Renders a comparison section showing code differences.

  ## Attributes
  * `title` - Section title
  * `comparisons` - List of comparison maps with :title and :code
  * `class` - Additional CSS classes
  """
  attr :title, :string, required: true
  attr :comparisons, :list, required: true
  attr :class, :string, default: ""

  def code_comparison(assigns) do
    ~H"""
    <div class={["bg-base-200 border border-base-300 rounded-lg p-4", @class]}>
      <h3 class="font-semibold text-base-content mb-2">{@title}</h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
        <%= for comparison <- @comparisons do %>
          <div>
            <h4 class="font-medium text-base-content/80 mb-1">{comparison.title}</h4>
            <pre class="bg-base-100 p-2 rounded border text-base-content overflow-x-auto"><code><%= comparison.code %></code></pre>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a tabbed info panel that combines navigation and content.

  ## Attributes
  * `tabs` - List of tab maps with :key, :label, :content
  * `current` - Current active tab index
  * `event` - Phoenix event name to trigger on tab click
  * `show_tabs` - Whether to show the tab navigation (default: true)
  * `class` - Additional CSS classes
  """
  attr :tabs, :list, required: true
  attr :current, :any, required: true
  attr :event, :string, required: true
  attr :show_tabs, :boolean, default: true
  attr :class, :string, default: ""

  def tabbed_info_panel(assigns) do
    ~H"""
    <div class={["bg-base-100 border border-base-300 rounded-lg overflow-hidden", @class]}>
      <!-- Tab Navigation (conditionally shown) -->
      <%= if @show_tabs do %>
        <div class="border-b border-base-300 bg-base-200">
          <nav class="flex space-x-1 p-1">
            <%= for tab <- @tabs do %>
              <button
                phx-click={@event}
                phx-value-option={tab.key}
                class={[
                  "px-3 py-2 text-sm font-medium rounded-md transition-all duration-200",
                  "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-inset",
                  get_tab_classes(tab.key == @current)
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
        <%= case Enum.find(@tabs, &(&1.key == @current)) do %>
          <% %{content: content} when is_binary(content) -> %>
            {Phoenix.HTML.raw(content)}
          <% %{content_slot: content_slot} -> %>
            {render_slot(content_slot)}
          <% tab -> %>
            <%= if tab do %>
              {Phoenix.HTML.raw(tab.content)}
            <% end %>
        <% end %>
      </div>
    </div>
    """
  end

    @doc """
  Renders a tabbed info panel that combines navigation and content.

  ## Attributes
  * `tabs` - List of tab maps with :key, :label, :content
  * `current` - Current active tab index
  * `event` - Phoenix event name to trigger on tab click
  * `show_tabs` - Whether to show the tab navigation (default: true)
  * `class` - Additional CSS classes
  """
  attr :tabs, :list, required: true
  attr :current, :integer, default: 0
  attr :event, :string, required: true
  attr :show_tabs, :boolean, default: true
  attr :class, :string, default: "tabdiv"
  attr :myself, :any
  def new_tabbed_info_panel(assigns) do
  ~H"""
  <div class={["bg-base-100 border border-base-300 rounded-lg overflow-hidden", @class]}>
  <p>Show tabs: {inspect(@show_tabs)}</p>
    <!-- Tab Navigation -->
    <%= if @show_tabs do %>
      <div class="border-b border-base-300 bg-base-200">
        <nav class="flex space-x-1 p-1">
          <%= for {tab, idx} <- Enum.with_index(@tabs) do %>
            <button
              phx-click="switch_tab"
              phx-value-index={idx}
              phx-target={@myself}
              class={[
                "px-3 py-2 text-sm font-medium rounded-md transition-all duration-200",
                "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-inset",
                get_tab_classes(idx == @current)
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
      <%= case Enum.at(@tabs, @current) do %>
        <% %{content: content} when is_binary(content) -> %>
          {Phoenix.HTML.raw(content)}
        <% %{content_slot: content_slot} -> %>
          {render_slot(content_slot)}
        <% tab -> %>
          <%= if tab do %>
            {Phoenix.HTML.raw(tab.content)}
          <% end %>
      <% end %>
    </div>
  </div>
  """
end


  # Private helper functions

  defp get_button_classes(true) do
    [
      "bg-primary text-primary-content shadow-md",
      "hover:bg-primary/80 active:bg-primary/60",
      "border-2 border-primary"
    ]
  end

  defp get_button_classes(false) do
    [
      "bg-base-200 text-base-content border-2 border-base-300",
      "hover:bg-base-300 hover:border-base-content/20",
      "active:bg-base-content/20"
    ]
  end

  defp get_toggle_classes(true, color) do
    case color do
      "blue" -> "bg-primary text-primary-content hover:bg-primary/80"
      "green" -> "bg-success text-success-content hover:bg-success/80"
      "red" -> "bg-error text-error-content hover:bg-error/80"
      "purple" -> "bg-secondary text-secondary-content hover:bg-secondary/80"
      _ -> "bg-neutral text-neutral-content hover:bg-neutral/80"
    end
  end

  defp get_toggle_classes(false, _color) do
    "bg-base-300 text-base-content hover:bg-base-content/20"
  end

  defp get_panel_classes(color) do
    case color do
      "blue" -> "bg-primary/10 border-primary/20"
      "green" -> "bg-success/10 border-success/20"
      "purple" -> "bg-secondary/10 border-secondary/20"
      "amber" -> "bg-warning/10 border-warning/20"
      "red" -> "bg-error/10 border-error/20"
      _ -> "bg-base-200 border-base-300"
    end
  end

  defp get_title_classes(color) do
    case color do
      "blue" -> "text-primary"
      "green" -> "text-success"
      "purple" -> "text-secondary"
      "amber" -> "text-warning"
      "red" -> "text-error"
      _ -> "text-base-content"
    end
  end

  defp get_content_classes(color) do
    case color do
      "blue" -> "text-primary/80"
      "green" -> "text-success/80"
      "purple" -> "text-secondary/80"
      "amber" -> "text-warning/80"
      "red" -> "text-error/80"
      _ -> "text-base-content/80"
    end
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
