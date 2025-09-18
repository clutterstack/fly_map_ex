defmodule DemoWeb.Content.StageTemplate do
  @moduledoc """
  A template live_component to render content from within PageLive.

  For each tab defined in the content module, renders:
  * a `FlyMapEx.node_map` component
  * a content panel with a tab switcher (if there's more than one tab), and
  * a panel showing the code to invoke the map component.
  """

  use DemoWeb, :live_component
  require Logger

  import DemoWeb.Components.NewControls

  def mount(socket) do
    {:ok,
     socket
     |> assign(:current_tab, 0)}
  end

  # attr :page_module, :any, required: true

  attr :tabs, :list, required: true
  attr :click_target, :string
  attr :class, :string, default: nil
  attr :show_tabs, :boolean, default: true
  attr :current_tab, :integer, default: 0
  attr :examples, :any, required: true
  attr :get_focused_code, :any, required: true
  attr :tab_data, :any

  def render(assigns) do
    # assigns = %{assigns | tabies: get_tabs(assigns.page_module)}
    tabs = get_tabs(assigns.page_module)

    assigns =
      assigns
      |> assign_new(:tabs, fn -> tabs end)
      |> assign_new(:tab_data, fn ->
        get_tab_data(assigns.page_module, tabs, assigns.current_tab)
      end)

    ~H"""
    <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8" id="content-panels">
      <!-- Map Panel -->
      <.stage_map {@tab_data.example} />
      <!-- Tabbed Info Panel -->
      <.new_tabbed_info_panel
        tabs={@tabs}
        current_tab={@current_tab}
        class={@class}
        show_tabs={@show_tabs}
        click_target={@myself}
        tab_content={@tab_data.content}
        tab_example={@tab_data.example}
      />
      <!-- Code Examples Panel -->
      <.code_example_panel {@tab_data.example} />
    </div>
    """
  end

  def handle_event("switch_tab", %{"index" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    Logger.info("Switching to tab #{idx}")
    {:noreply, assign(socket, :current_tab, idx)}
  end

  def code_example_panel(assigns) do
    ~H"""
    <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
      <!-- Quick Stats -->
      <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
        <div class="text-sm text-primary">
          {@description} • {if @marker_groups, do: get_groups_count(@marker_groups), else: 0} groups • {count_total_nodes(
            @marker_groups
          )} nodes
        </div>
      </div>
      <div class="p-4">
        <pre class="text-sm text-base-content whitespace-pre-wrap overflow-x-auto bg-base-200 p-3 rounded"><code><%= DemoWeb.Helpers.CodeGenerator.generate_heex_template(@marker_groups, nil, nil, "code comment") %>
          </code></pre>
      </div>
    </div>
    """
  end

  @doc """
  Renders the full-width map display.
  """
  attr :marker_groups, :list, required: true
  attr :layout, :atom, default: :side_by_side
  attr :theme, :any, default: nil

  def stage_map(assigns) do
    ~H"""
    <div class="bg-base-100 rounded-lg col-span-2">
      <FlyMapEx.node_map marker_groups={@marker_groups} layout={@layout} theme={@theme} />
    </div>
    """
  end

  # defp content(page_module) do
  #   apply(page_module, :get_content, [])
  # end

  defp get_tabs(page_module) do
    apply(page_module, :tabs, [])
  end

  defp get_tab_data(page_module, tabs, idx) do
    key = get_tab_key(tabs, idx)
    apply(page_module, :get_content, [key])
  end

  defp get_tab_key(tabs, idx) do
    Enum.at(tabs, idx).key
  end

  defp get_groups_count(groups) when is_nil(groups), do: 0
  defp get_groups_count(groups) when is_list(groups), do: length(groups)
  defp get_groups_count(_), do: 1

  defp count_total_nodes(groups) when is_nil(groups), do: 0

  defp count_total_nodes(groups) when is_list(groups) do
    Enum.reduce(groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end

  defp count_total_nodes(_), do: 0

  # get_content("custom_regions").content
end
