defmodule DemoWeb.Components.Navigation do
  use Phoenix.Component

  @doc """
  Renders a navigation component with configurable layout.

  ## Examples

      <.navigation layout={:sidebar} current_page={:stage1} />
      <.navigation layout={:topbar} current_page={:map_demo} />
      <.navigation layout={:sidebar} current_page={:stage1} tabs={@tabs} current_tab={@current_example} />
  """
  attr :layout, :atom, required: true, values: [:sidebar, :topbar]
  attr :current_page, :atom, required: true
  attr :class, :string, default: ""
  attr :tabs, :list, default: []
  attr :current_tab, :string, default: nil

  def navigation(%{layout: :sidebar} = assigns) do
    ~H"""
    <nav class={["flex flex-col h-full", @class]}>
      <!-- Logo/Header -->
      <div class="p-4 border-b border-base-300">
        <.link navigate="/" class="text-xl font-bold text-base-content hover:text-base-content/70">
          FlyMapEx Demo
        </.link>
      </div>
      
    <!-- Navigation Links -->
      <div class="flex-1 overflow-y-auto">
        <nav class="px-2 py-4 space-y-1">
          <%= for {path, title, key} <- nav_items() do %>
            <.link navigate={path} class={sidebar_nav_link_class(@current_page, key)}>
              {title}
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
                    {tab.label}
                  </button>
                <% end %>
              </div>
            <% end %>
          <% end %>
        </nav>
      </div>
    </nav>
    """
  end

  def navigation(%{layout: :topbar} = assigns) do
    ~H"""
    <nav class={"bg-base-100 border-b border-base-300 shadow-sm #{@class}"}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <.link
                navigate="/"
                class="text-xl font-bold text-base-content hover:text-base-content/70"
              >
                FlyMapEx Demo
              </.link>
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <%= for {path, title, key} <- nav_items() do %>
                <.link navigate={path} class={topbar_nav_link_class(@current_page, key)}>
                  {title}
                </.link>
              <% end %>
            </div>
          </div>
          
    <!-- Mobile menu button -->
          <div class="sm:hidden flex items-center">
            <button
              type="button"
              class="inline-flex items-center justify-center p-2 rounded-md text-base-content/60 hover:text-base-content/70 hover:bg-base-200 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-primary"
              aria-controls="mobile-menu"
              aria-expanded="false"
              x-data="{ open: false }"
              @click="open = !open"
            >
              <span class="sr-only">Open main menu</span>
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
      
    <!-- Mobile menu -->
      <div class="sm:hidden" id="mobile-menu" x-data="{ open: false }" x-show="open">
        <div class="pt-2 pb-3 space-y-1">
          <%= for {path, title, key} <- nav_items() do %>
            <.link navigate={path} class={mobile_nav_link_class(@current_page, key)}>
              {title}
            </.link>
          <% end %>
        </div>
      </div>
    </nav>
    """
  end

  defp nav_items do
    # Static page navigation items (dead views)
    # path, label, module
    static_pages = [
      {"/", "Home", :home},
      {"/about", "About", :about},
      {"/demo", "Demo", :demo}
    ]

    # LiveView navigation items
    live_view_items = [
      {"/stage3", "The Map", :stage3},
      {"/live_layout", "Testing Live Layout", :live_with_layout},
      {"/stage1", "Placing Markers", :stage1},
      {"/stage2", "Marker Styles", :stage2},
      {"/stage4", "Builder", :stage4},
      {"/map", "Machine Map", :machine_map},
      {"/node_placement", "Node placement with PageLive", :page_live}
    ]

    static_pages ++ live_view_items
  end

  defp sidebar_nav_link_class(current_page, page_key) do
    base_class =
      "group flex items-center px-2 py-2 text-sm font-medium rounded-md transition-colors"

    if current_page == page_key do
      "#{base_class} bg-primary/10 text-primary border-r-2 border-primary"
    else
      "#{base_class} text-base-content/70 hover:text-base-content hover:bg-base-200"
    end
  end

  defp tab_nav_link_class(current_tab, tab_key) do
    base_class =
      "group flex items-center px-2 py-1 text-xs font-medium rounded-md transition-colors w-full text-left"

    if current_tab == tab_key do
      "#{base_class} bg-primary/20 text-primary"
    else
      "#{base_class} text-base-content/60 hover:text-base-content/80 hover:bg-base-200"
    end
  end

  defp topbar_nav_link_class(current_page, page_key) do
    base_class =
      "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors"

    if current_page == page_key do
      "#{base_class} border-primary text-base-content"
    else
      "#{base_class} border-transparent text-base-content/70 hover:text-base-content/80 hover:border-base-300"
    end
  end

  defp mobile_nav_link_class(current_page, page_key) do
    base_class = "block pl-3 pr-4 py-2 border-l-4 text-base font-medium transition-colors"

    if current_page == page_key do
      "#{base_class} bg-primary/10 border-primary text-primary"
    else
      "#{base_class} border-transparent text-base-content/70 hover:text-base-content/80 hover:bg-base-200 hover:border-base-300"
    end
  end
end
