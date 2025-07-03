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
            "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2",
            get_button_classes(option.key == @current)
          ]}
          title={option[:description]}
        >
          <%= option.label %>
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
        "focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2",
        get_toggle_classes(@active, @active_color),
        @class
      ]}
    >
      <%= if @active, do: @active_label, else: @inactive_label %>
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
        <%= @title %>
      </h3>
      <div class={get_content_classes(@color)}>
        <%= render_slot(@inner_block) %>
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
    <div class={["bg-gray-50 border border-gray-200 rounded-lg p-4", @class]}>
      <h3 class="font-semibold text-gray-800 mb-2"><%= @title %></h3>
      <div class="grid grid-cols-1 md:grid-cols-2 gap-4 text-xs">
        <%= for comparison <- @comparisons do %>
          <div>
            <h4 class="font-medium text-gray-700 mb-1"><%= comparison.title %></h4>
            <pre class="bg-white p-2 rounded border text-gray-800 overflow-x-auto"><code><%= comparison.code %></code></pre>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
  
  # Private helper functions
  
  defp get_button_classes(true) do
    [
      "bg-blue-600 text-white shadow-md",
      "hover:bg-blue-700 active:bg-blue-800",
      "border-2 border-blue-600"
    ]
  end
  
  defp get_button_classes(false) do
    [
      "bg-gray-100 text-gray-700 border-2 border-gray-200",
      "hover:bg-gray-200 hover:border-gray-300",
      "active:bg-gray-300"
    ]
  end
  
  defp get_toggle_classes(true, color) do
    case color do
      "blue" -> "bg-blue-600 text-white hover:bg-blue-700"
      "green" -> "bg-green-600 text-white hover:bg-green-700"
      "red" -> "bg-red-600 text-white hover:bg-red-700"
      "purple" -> "bg-purple-600 text-white hover:bg-purple-700"
      _ -> "bg-gray-600 text-white hover:bg-gray-700"
    end
  end
  
  defp get_toggle_classes(false, _color) do
    "bg-gray-200 text-gray-700 hover:bg-gray-300"
  end
  
  defp get_panel_classes(color) do
    case color do
      "blue" -> "bg-blue-50 border-blue-200"
      "green" -> "bg-green-50 border-green-200"
      "purple" -> "bg-purple-50 border-purple-200"
      "amber" -> "bg-amber-50 border-amber-200"
      "red" -> "bg-red-50 border-red-200"
      _ -> "bg-gray-50 border-gray-200"
    end
  end
  
  defp get_title_classes(color) do
    case color do
      "blue" -> "text-blue-800"
      "green" -> "text-green-800"
      "purple" -> "text-purple-800"
      "amber" -> "text-amber-800"
      "red" -> "text-red-800"
      _ -> "text-gray-800"
    end
  end
  
  defp get_content_classes(color) do
    case color do
      "blue" -> "text-blue-700"
      "green" -> "text-green-700"
      "purple" -> "text-purple-700"
      "amber" -> "text-amber-700"
      "red" -> "text-red-700"
      _ -> "text-gray-700"
    end
  end
end