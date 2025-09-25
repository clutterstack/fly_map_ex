defmodule DemoWeb.Content.StageTemplate do
  @moduledoc """
  A template live_component to render content from within PageLive.

  For each tab defined in the content module, renders:
  * a `FlyMapEx.render` component
  * a content panel with a tab switcher (if there's more than one tab), and
  * a panel showing the code to invoke the map component.
  """

  use DemoWeb, :live_component
  require Logger

  import DemoWeb.Components.NewControls
  import DemoWeb.Components.ValidatedTemplate

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
      <.stage_map validated_example={@tab_data.example} />

      <!-- Tabbed Info Panel -->
      <.tabbed_info_panel
        tabs={@tabs}
        current_tab={@current_tab}
        class={@class}
        show_tabs={@show_tabs}
        click_target={@myself}
        tab_content={@tab_data.content}
        tab_example={@tab_data.example}
      />

      <!-- Code Examples Panel -->
      <.code_example_panel validated_example={@tab_data.example} />
    </div>
    """
  end

  def handle_event("switch_tab", %{"index" => idx_str}, socket) do
    idx = String.to_integer(idx_str)
    Logger.info("Switching to tab #{idx}")
    {:noreply, assign(socket, :current_tab, idx)}
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


  # get_content("custom_regions").content
end
