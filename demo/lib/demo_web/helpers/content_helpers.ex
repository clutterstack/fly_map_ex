defmodule DemoWeb.Helpers.ContentHelpers do
  @moduledoc """
  Function components for generating consistent HTML content across stage components.

  This module provides utilities for creating standardized content sections,
  formatting, and DaisyUI-styled components used throughout the demo application.
  """

  use Phoenix.Component
  import Phoenix.HTML

  @doc """
  Converts a string from Markdown to HTML.
  Takes a string (use heredocs for multiple lines)
  """
  def convert_markdown(markdown, opts \\ []) do
    earmark_opts = Keyword.get(opts, :earmark_options, %Earmark.Options{})
    Earmark.as_html!(markdown, earmark_opts)
  end

  @doc """
  Renders markdown content as a function component.
  """
  attr :content, :string, required: true
  attr :class, :string, default: ""

  def markdown(assigns) do
    ~H"""
    <div class={@class}>
      {raw(convert_markdown(@content))}
    </div>
    """
  end

  @doc """
  Creates a standardized content section with title and description. Converts
  `description` from Markdown
  """
  def content_section(title, description, opts \\ []) do
    class = Keyword.get(opts, :class, "space-y-4 list-disc")

    ~s"""
    <div class="#{class}">
      <div>
        <h4 class="font-semibold text-base-content mb-2">#{title}</h4>
        <div class="text-sm text-base-content/70 mb-3">
          #{convert_markdown(description, opts)}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Creates a standardized content section as a function component.
  """
  attr :title, :string, required: true
  attr :description, :string, default: nil
  attr :class, :string, default: "space-y-4 list-disc"
  slot :inner_block, required: false

  def content_section_component(assigns) do
    ~H"""
    <div class={@class}>
      <div>
        <h4 class="font-semibold text-base-content mb-2">{@title}</h4>
        <%= if @description do %>
          <div class="text-sm text-base-content/70 mb-3">
            {raw(convert_markdown(@description))}
          </div>
        <% end %>
        <%= if @inner_block != [] do %>
          {render_slot(@inner_block)}
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Creates an info box with semantic styling.
  """
  def info_box(type, title, content, opts \\ []) do
    {bg_class, border_class, text_class} = get_semantic_classes(type)
    extra_class = Keyword.get(opts, :class, "")

    ~s"""
    <div class="#{bg_class} #{border_class} rounded-lg p-4 #{extra_class}">
      <h5 class="font-medium #{text_class} mb-2">#{title}</h5>
      #{content}
    </div>
    """
  end

  @doc """
  Creates an info box with semantic styling as a function component.
  """
  attr :type, :atom, required: true
  attr :title, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def info_box_component(assigns) do
    {bg_class, border_class, text_class} = get_semantic_classes(assigns.type)

    assigns = assign(assigns, :bg_class, bg_class)
    assigns = assign(assigns, :border_class, border_class)
    assigns = assign(assigns, :text_class, text_class)

    ~H"""
    <div class={[@bg_class, @border_class, "rounded-lg p-4", @class]}>
      <h5 class={["font-medium mb-2", @text_class]}>{@title}</h5>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Creates a code snippet with proper formatting.
  """
  def code_snippet(code, opts \\ []) do
    inline = Keyword.get(opts, :inline, false)

    if inline do
      ~s(<code class="bg-base-100 px-1 rounded">#{code}</code>)
    else
      ~s(<pre class="bg-base-200 p-4 rounded-lg text-sm"><code>#{code}</code></pre>)
    end
  end

  @doc """
  Creates a code snippet as a function component.
  """
  attr :code, :string, required: true
  attr :inline, :boolean, default: false
  attr :class, :string, default: ""

  def code_snippet_component(assigns) do
    ~H"""
    <%= if @inline do %>
      <code class={["bg-base-100 px-1 rounded", @class]}>{@code}</code>
    <% else %>
      <pre class={["bg-base-200 p-4 rounded-lg text-sm", @class]}><code><%= @code %></code></pre>
    <% end %>
    """
  end

  @doc """
  Creates a feature list with consistent styling.
  """
  def titled_list(items, opts \\ []) do
    type = Keyword.get(opts, :type, :bullets)
    class = Keyword.get(opts, :class, "text-sm text-base-content/70 space-y-1")

    list_items =
      Enum.map(items, fn item ->
        marker =
          case type do
            :bullets -> "•"
            :arrows -> "→"
            :checks -> "✓"
            _ -> "•"
          end

        "<li>#{marker} #{item}</li>"
      end)

    ~s"""
    <ul class="#{class}">
      #{Enum.join(list_items, "\n")}
    </ul>
    """
  end

  @doc """
  Creates a feature list as a function component.
  """
  attr :items, :list, required: true
  attr :type, :atom, default: :bullets
  attr :class, :string, default: "text-sm text-base-content/70 space-y-1"

  def titled_list_component(assigns) do
    marker =
      case assigns.type do
        :bullets -> "•"
        :arrows -> "→"
        :checks -> "✓"
        _ -> "•"
      end

    assigns = assign(assigns, :marker, marker)

    ~H"""
    <ul class={@class}>
      <%= for item <- @items do %>
        <li>{@marker} {raw(item)}</li>
      <% end %>
    </ul>
    """
  end

  @doc """
  Creates a color indicator with label.
  """
  def color_indicator(color, label, opts \\ []) do
    size = Keyword.get(opts, :size, "w-4 h-4")
    animated = Keyword.get(opts, :animated, false)

    animation_class = if animated, do: "animate-pulse", else: ""

    ~s"""
    <div class="flex items-center space-x-2">
      <div class="#{size} rounded-full #{color} #{animation_class}"></div>
      <span class="text-sm">#{label}</span>
    </div>
    """
  end

  @doc """
  Creates a grid of color indicators.
  """
  def color_grid(colors, opts \\ []) do
    cols = Keyword.get(opts, :cols, 2)
    gap = Keyword.get(opts, :gap, "gap-2")

    items =
      Enum.map(colors, fn {color, label} ->
        color_indicator(color, label, opts)
      end)

    ~s"""
    <div class="grid grid-cols-#{cols} #{gap} text-sm">
      #{Enum.join(items, "\n")}
    </div>
    """
  end

  @doc """
  Creates a pro tip box with consistent styling.
  """
  def pro_tip(content, opts \\ []) do
    type = Keyword.get(opts, :type, :tip)

    {bg_class, border_class, text_class, icon} =
      case type do
        :tip -> {"bg-base-200", "border-base-300", "text-base-content/70", "Pro Tip:"}
        :warning -> {"bg-warning/10", "border-warning/20", "text-warning", "Warning:"}
        :best_practice -> {"bg-primary/10", "border-primary/20", "text-primary", "Best Practice:"}
        :production -> {"bg-success/10", "border-success/20", "text-success", "Production Tip:"}
        _ -> {"bg-base-200", "border-base-300", "text-base-content/70", "Note:"}
      end

    ~s"""
    <div class="#{bg_class} border #{border_class} rounded-lg p-3">
      <p class="text-xs #{text_class}">
        <strong>#{icon}</strong> #{content}
      </p>
    </div>
    """
  end

  @doc """
  Creates a pro tip box as a function component.
  """
  attr :type, :atom, default: :tip
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def pro_tip_component(assigns) do
    {bg_class, border_class, text_class, icon} =
      case assigns.type do
        :tip -> {"bg-base-200", "border-base-300", "text-base-content/70", "Pro Tip:"}
        :warning -> {"bg-warning/10", "border-warning/20", "text-warning", "Warning:"}
        :best_practice -> {"bg-primary/10", "border-primary/20", "text-primary", "Best Practice:"}
        :production -> {"bg-success/10", "border-success/20", "text-success", "Production Tip:"}
        _ -> {"bg-base-200", "border-base-300", "text-base-content/70", "Note:"}
      end

    assigns = assign(assigns, :bg_class, bg_class)
    assigns = assign(assigns, :border_class, border_class)
    assigns = assign(assigns, :text_class, text_class)
    assigns = assign(assigns, :icon, icon)

    ~H"""
    <div class={[@bg_class, "border", @border_class, "rounded-lg p-3", @class]}>
      <p class={["text-xs", @text_class]}>
        <strong>{@icon}</strong> {render_slot(@inner_block)}
      </p>
    </div>
    """
  end

  @doc """
  Creates parameter documentation with examples.
  """
  def parameter_doc(name, type, description, example \\ nil) do
    example_html =
      if example do
        ~s"""
        <div class="mt-1">
          <strong>Example:</strong> #{code_snippet(example, inline: true)}
        </div>
        """
      else
        ""
      end

    ~s"""
    <div class="space-y-1">
      <div>
        <strong>#{name}:</strong> #{description}
      </div>
      <div class="text-xs text-base-content/60">
        Type: #{type}
      </div>
      #{example_html}
    </div>
    """
  end

  @doc """
  Creates parameter documentation as a function component.
  """
  attr :name, :string, required: true
  attr :type, :string, required: true
  attr :description, :string, required: true
  attr :example, :string, default: nil

  def parameter_doc_component(assigns) do
    ~H"""
    <div class="space-y-1">
      <div>
        <strong>{@name}:</strong> {@description}
      </div>
      <div class="text-xs text-base-content/60">
        Type: {@type}
      </div>
      <%= if @example do %>
        <div class="mt-1">
          <strong>Example:</strong> <.code_snippet_component code={@example} inline={true} />
        </div>
      <% end %>
    </div>
    """
  end

  @doc """
  Creates a use case section with examples.
  """
  def ul_with_bold(title, cases, opts \\ []) do
    class = Keyword.get(opts, :class, "")

    case_items =
      Enum.map(cases, fn {use_case, description} ->
        "<li><strong>#{use_case}:</strong> #{description}</li>"
      end)

    ~s"""
    <div class="#{class}">
      <h5 class="font-medium text-base-content mb-2">#{title}</h5>
      <ul class="text-sm text-base-content/70 space-y-1">
        #{Enum.join(case_items, "\n")}
      </ul>
    </div>
    """
  end

  @doc """
  Creates a use case section as a function component.
  """
  attr :title, :string, required: true
  attr :cases, :list, required: true
  attr :class, :string, default: ""

  def ul_with_bold_component(assigns) do
    ~H"""
    <div class={@class}>
      <h5 class="font-medium text-base-content mb-2">{@title}</h5>
      <ul class="text-sm text-base-content/70 space-y-1">
        <%= for {use_case, description} <- @cases do %>
          <li><strong>{use_case}:</strong> {description}</li>
        <% end %>
      </ul>
    </div>
    """
  end

  @doc """
  Creates a step-by-step status display.
  """
  def status_steps(steps, opts \\ []) do
    gap = Keyword.get(opts, :gap, "space-y-3")

    step_items =
      Enum.map(steps, fn {_status, title, description, color} ->
        ~s"""
        <div class="flex items-start space-x-3 p-3 #{color}/10 border #{color}/20 rounded-lg">
          <div class="w-4 h-4 rounded-full #{color} mt-0.5"></div>
          <div>
            <h5 class="font-medium #{color}">#{title}</h5>
            <p class="text-sm #{color}/80">#{description}</p>
          </div>
        </div>
        """
      end)

    ~s"""
    <div class="#{gap}">
      #{Enum.join(step_items, "\n")}
    </div>
    """
  end

  # Private helper functions

  defp get_semantic_classes(type) do
    case type do
      :primary -> {"bg-primary/10", "border border-primary/20", "text-primary"}
      :success -> {"bg-success/10", "border border-success/20", "text-success"}
      :warning -> {"bg-warning/10", "border border-warning/20", "text-warning"}
      :error -> {"bg-error/10", "border border-error/20", "text-error"}
      :secondary -> {"bg-secondary/10", "border border-secondary/20", "text-secondary"}
      :info -> {"bg-info/10", "border border-info/20", "text-info"}
      _ -> {"bg-base-200", "border border-base-300", "text-base-content"}
    end
  end
end
