defmodule DemoWeb.Components.SidebarNavigation do
  use Phoenix.Component
  import DemoWeb.Layouts, only: [theme_toggle: 1]

  @doc """
  Renders a vertical navigation component for the sidebar.

  ## Examples

      <.sidebar_navigation current_page={:stage1} />
      <.sidebar_navigation current_page={:map_demo} />
      <.sidebar_navigation current_page={:stage1} tabs={@tabs} current_tab={@current_example} />
  """
  attr :current_page, :atom, required: true
  attr :class, :string, default: ""
  attr :tabs, :list, default: []
  attr :current_tab, :string, default: nil

  def sidebar_navigation(assigns) do
    ~H"""
    <nav class={["flex flex-col h-full", @class]}>
      <!-- Logo/Header -->
      <div class="p-4 border-b border-base-300">
        <.link
          navigate="/"
          class="text-xl font-bold text-base-content hover:text-base-content/70"
        >
          FlyMapEx Demo
        </.link>
      </div>

      <!-- Navigation Links -->
      <div class="flex-1 overflow-y-auto">
        <nav class="px-2 py-4 space-y-1">
          <%= for {path, title, key} <- nav_items() do %>
            <.link
              navigate={path}
              class={sidebar_nav_link_class(@current_page, key)}
            >
              <%= title %>
            </.link>

            <!-- Show tabs as nested items if this is the current page and tabs are provided -->
            <%= if @current_page == key and length(@tabs) > 0 do %>
              <div class="ml-4 mt-2 space-y-1">
                <%= for tab <- @tabs do %>
                  <button
                    phx-click="switch_example"
                    phx-value-option={tab.key}
                    class={tab_nav_link_class(@current_tab, tab.key)}
                  >
                    <%= tab.label %>
                  </button>
                <% end %>
              </div>
            <% end %>
          <% end %>
        </nav>
      </div>

      <!-- Theme Toggle -->
      <div class="p-4 border-t border-base-300">
        <.theme_toggle />
      </div>
    </nav>
    """
  end

  defp nav_items do
    [
      {"/", "Home", :map_demo},
      {"/stage1", "Placing markers", :stage1},
      {"/stage2", "Stage 2: Groups", :stage2},
      {"/stage3", "Stage 3: Themes", :stage3},
      {"/stage4", "Stage 4: Builder", :stage4},
      {"/map", "Machine Map", :machine_map}
    ]
  end

  defp sidebar_nav_link_class(current_page, page_key) do
    base_class = "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors"

    if current_page == page_key do
      "#{base_class} bg-primary/10 text-primary border-r-2 border-primary"
    else
      "#{base_class} text-base-content/70 hover:text-base-content hover:bg-base-200"
    end
  end

  defp tab_nav_link_class(current_tab, tab_key) do
    base_class = "group flex items-center px-2 py-1 text-xs font-medium rounded-md transition-colors w-full text-left"

    if current_tab == tab_key do
      "#{base_class} bg-primary/20 text-primary"
    else
      "#{base_class} text-base-content/60 hover:text-base-content/80 hover:bg-base-200"
    end
  end
end
