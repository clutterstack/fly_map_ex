defmodule DemoWeb.Components.ValidatedTemplate do
  @moduledoc """
  Unified renderer for validated FlyMapEx templates.

  This component takes a validated template (created with ValidatedExample.validated_template/1)
  and renders both the live map component and the code display panel from a single source of truth.

  ## Usage

  ```elixir
  <.validated_template_display validated_example={@validated_example} />
  ```

  The validated_example should be a map containing:
  - `:template` - The original HEEx template string for code display
  - `:assigns` - Parsed and validated assigns for component rendering
  - `:description` - Generated description of the template
  """

  use Phoenix.Component
  import Phoenix.HTML
  alias DemoWeb.Helpers.SyntaxHighlighter

  @doc """
  Renders the map component using the validated template assigns.
  """
  attr :validated_example, :map, required: true
  attr :class, :string, default: nil

  def stage_map(assigns) do
    ~H"""
    <div class={["bg-base-100 rounded-lg col-span-2", @class]}>
      <FlyMapEx.render {@validated_example.assigns} />
    </div>
    """
  end

  @doc """
  Renders the code example panel showing the template source and statistics.
  """
  attr :validated_example, :map, required: true

  def code_example_panel(assigns) do
    assigns = assign(assigns, :stats, calculate_stats(assigns.validated_example))

    ~H"""
    <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
      <!-- Quick Stats -->
      <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
        <div class="text-sm text-primary">
          {@validated_example.description} • {@stats.group_count} groups • {@stats.node_count} nodes
        </div>
      </div>

      <!-- Template Code Display -->
      <div class="p-4">
        <div class="syntax-highlight text-sm bg-base-200 p-3 rounded overflow-x-auto">
          {raw(highlight_template(@validated_example.template))}
        </div>
      </div>
    </div>
    """
  end

  @doc """
  Complete validated template display component that renders both map and code panels.

  This is the main component that replaces the complex logic in StageTemplate.
  """
  attr :validated_example, :map, required: true
  attr :tab_content, :any, default: nil
  attr :class, :string, default: nil

  def validated_template_display(assigns) do
    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8" id="content-panels">
      <!-- Map Panel -->
      <.stage_map validated_example={@validated_example} />

      <!-- Content Panel (if provided) -->
      <%= if @tab_content do %>
        <div class="bg-base-100 border border-base-300 rounded-lg p-6">
          <div class="prose prose-sm max-w-none">
            <%= raw(@tab_content) %>
          </div>
        </div>
      <% end %>

      <!-- Code Examples Panel -->
      <.code_example_panel validated_example={@validated_example} />
    </div>
    """
  end

  # Private helper functions

  defp calculate_stats(validated_example) do
    marker_groups = validated_example.assigns[:marker_groups] || []
    group_count = length(marker_groups)

    node_count =
      marker_groups
      |> Enum.flat_map(fn group -> group[:nodes] || [] end)
      |> length()

    %{
      group_count: group_count,
      node_count: node_count
    }
  end

  defp highlight_template(template_string) do
    # Clean up, format, and highlight the template
    formatted_template =
      template_string
      |> String.trim()
      |> format_multiline_template()

    SyntaxHighlighter.highlight_code(formatted_template, :heex)
  end


  defp format_multiline_template(template) do
    # If template is on multiple lines, preserve formatting
    # If it's a single line, make it multi-line for readability
    if String.contains?(template, "\n") do
      template
    else
      # Convert single-line template to formatted multi-line
      format_single_line_template(template)
    end
  end

  defp format_single_line_template(template) do
    # Basic formatting for single-line templates
    template
    |> String.replace(~r/<FlyMapEx\.render\s+/, "<FlyMapEx.render\n  ")
    |> String.replace(~r/\s+(\w+=)/, "\n  \\1")
    |> String.replace(~r/\s*\/>/, "\n/>")
  end
end