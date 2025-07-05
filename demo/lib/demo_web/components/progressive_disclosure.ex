defmodule DemoWeb.Components.ProgressiveDisclosure do
  @moduledoc """
  Components for progressive disclosure of advanced topics and detailed information.

  These components help maintain the "above the fold" principle by showing key concepts
  first and providing expandable sections for deeper exploration.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders an expandable section that starts collapsed.

  ## Attributes
  * `title` - The header title for the section
  * `id` - Unique identifier for the section
  * `open` - Boolean indicating if the section is open (default: false)
  * `color` - Color scheme for the section (default: "gray")
  * `class` - Additional CSS classes
  """
  attr :title, :string, required: true
  attr :id, :string, required: true
  attr :open, :boolean, default: false
  attr :color, :string, default: "gray"
  attr :class, :string, default: ""

  slot :inner_block, required: true

  def expandable_section(assigns) do
    ~H"""
    <div class={["border rounded-lg overflow-hidden", get_border_classes(@color), @class]}>
      <button
        type="button"
        class={[
          "w-full px-4 py-3 text-left flex items-center justify-between",
          "hover:bg-opacity-50 transition-colors duration-200",
          "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-inset",
          get_header_classes(@color)
        ]}
        phx-click={JS.toggle(to: "##{@id}-content") |> JS.toggle_class("rotate-180", to: "##{@id}-icon")}
      >
        <h3 class="font-semibold"><%= @title %></h3>
        <svg
          id={"#{@id}-icon"}
          class={["w-5 h-5 transition-transform duration-200", if(@open, do: "rotate-180", else: "")]}
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
        </svg>
      </button>

      <div
        id={"#{@id}-content"}
        class={[
          "px-4 py-3 border-t",
          get_content_classes(@color),
          unless(@open, do: "hidden", else: "")
        ]}
      >
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a tabs component for organizing related advanced topics.

  ## Attributes
  * `tabs` - List of tab maps with :id, :label, and :content
  * `active_tab` - ID of the currently active tab
  * `class` - Additional CSS classes
  """
  attr :tabs, :list, required: true
  attr :active_tab, :string, required: true
  attr :class, :string, default: ""

  def tabs_component(assigns) do
    ~H"""
    <div class={["", @class]}>
      <!-- Tab Headers -->
      <div class="flex space-x-1 border-b border-base-300">
        <%= for tab <- @tabs do %>
          <button
            type="button"
            class={[
              "px-4 py-2 font-medium text-sm rounded-t-lg transition-colors duration-200",
              "focus:outline-none focus:ring-2 focus:ring-primary focus:ring-inset",
              get_tab_classes(tab.id == @active_tab)
            ]}
            phx-click={show_tab(tab.id, @tabs)}
          >
            <%= tab.label %>
          </button>
        <% end %>
      </div>

      <!-- Tab Content -->
      <div class="mt-4">
        <%= for tab <- @tabs do %>
          <div
            id={"tab-#{tab.id}"}
            class={unless(tab.id == @active_tab, do: "hidden", else: "")}
          >
            <%= Phoenix.HTML.raw(tab.content) %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Renders a tooltip or popover for inline help.

  ## Attributes
  * `text` - The tooltip text
  * `position` - Position of the tooltip (default: "top")
  * `class` - Additional CSS classes
  """
  attr :text, :string, required: true
  attr :position, :string, default: "top"
  attr :class, :string, default: ""

  slot :inner_block, required: true

  def tooltip(assigns) do
    ~H"""
    <div class={["relative inline-block", @class]}>
      <div class="group">
        <%= render_slot(@inner_block) %>
        <div class={[
          "absolute z-10 px-3 py-2 text-sm font-medium text-base-100 bg-neutral rounded-lg shadow-sm",
          "opacity-0 group-hover:opacity-100 transition-opacity duration-300",
          "pointer-events-none whitespace-nowrap",
          get_tooltip_position(@position)
        ]}>
          <%= @text %>
          <div class={["absolute w-2 h-2 bg-neutral transform rotate-45", get_tooltip_arrow(@position)]}>
          </div>
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Renders a "Learn More" section with multiple expandable topics.

  ## Attributes
  * `topics` - List of topic maps with :title, :id, and :content
  * `class` - Additional CSS classes
  """
  attr :topics, :list, required: true
  attr :class, :string, default: ""

  def learn_more_section(assigns) do
    ~H"""
    <div class={["mt-8", @class]}>
      <h2 class="text-2xl font-bold text-base-content mb-4">Learn More</h2>
      <div class="space-y-3">
        <%= for topic <- @topics do %>
          <.expandable_section
            title={topic.title}
            id={topic.id}
            color="blue"
          >
            <%= Phoenix.HTML.raw(topic.content) %>
          </.expandable_section>
        <% end %>
      </div>
    </div>
    """
  end

  # Private helper functions

  defp get_border_classes(color) do
    case color do
      "blue" -> "border-primary/20"
      "green" -> "border-success/20"
      "purple" -> "border-secondary/20"
      "amber" -> "border-warning/20"
      "red" -> "border-error/20"
      _ -> "border-base-300"
    end
  end

  defp get_header_classes(color) do
    case color do
      "blue" -> "bg-primary/10 text-primary hover:bg-primary/20"
      "green" -> "bg-success/10 text-success hover:bg-success/20"
      "purple" -> "bg-secondary/10 text-secondary hover:bg-secondary/20"
      "amber" -> "bg-warning/10 text-warning hover:bg-warning/20"
      "red" -> "bg-error/10 text-error hover:bg-error/20"
      _ -> "bg-base-200 text-base-content hover:bg-base-300"
    end
  end

  defp get_content_classes(color) do
    case color do
      "blue" -> "bg-primary/5 border-primary/20"
      "green" -> "bg-success/5 border-success/20"
      "purple" -> "bg-secondary/5 border-secondary/20"
      "amber" -> "bg-warning/5 border-warning/20"
      "red" -> "bg-error/5 border-error/20"
      _ -> "bg-base-100 border-base-300"
    end
  end

  defp get_tab_classes(true) do
    "bg-base-100 text-primary border-b-2 border-primary"
  end

  defp get_tab_classes(false) do
    "bg-base-200 text-base-content/80 hover:bg-base-300 hover:text-base-content"
  end

  defp get_tooltip_position("top") do
    "bottom-full left-1/2 transform -translate-x-1/2 mb-2"
  end

  defp get_tooltip_position("bottom") do
    "top-full left-1/2 transform -translate-x-1/2 mt-2"
  end

  defp get_tooltip_position("left") do
    "right-full top-1/2 transform -translate-y-1/2 mr-2"
  end

  defp get_tooltip_position("right") do
    "left-full top-1/2 transform -translate-y-1/2 ml-2"
  end

  defp get_tooltip_arrow("top") do
    "top-full left-1/2 transform -translate-x-1/2 -mt-1"
  end

  defp get_tooltip_arrow("bottom") do
    "bottom-full left-1/2 transform -translate-x-1/2 -mb-1"
  end

  defp get_tooltip_arrow("left") do
    "left-full top-1/2 transform -translate-y-1/2 -ml-1"
  end

  defp get_tooltip_arrow("right") do
    "right-full top-1/2 transform -translate-y-1/2 -mr-1"
  end

  defp show_tab(active_id, tabs) do
    Enum.reduce(tabs, %JS{}, fn tab, js ->
      if tab.id == active_id do
        JS.show(js, to: "#tab-#{tab.id}")
      else
        JS.hide(js, to: "#tab-#{tab.id}")
      end
    end)
  end
end
