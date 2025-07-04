defmodule DemoWeb.Components.DemoNavigation do
  use Phoenix.Component

  @doc """
  Renders a navigation component for demo liveviews.
  
  ## Examples
  
      <.demo_navigation current_page={:stage1} />
      <.demo_navigation current_page={:map_demo} />
  """
  attr :current_page, :atom, required: true
  attr :class, :string, default: ""

  def demo_navigation(assigns) do
    ~H"""
    <nav class={"bg-white border-b border-gray-200 shadow-sm #{@class}"}>
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex">
            <div class="flex-shrink-0 flex items-center">
              <.link
                navigate="/"
                class="text-xl font-bold text-gray-900 hover:text-gray-700"
              >
                FlyMapEx Demo
              </.link>
            </div>
            <div class="hidden sm:ml-6 sm:flex sm:space-x-8">
              <%= for {path, title, key} <- nav_items() do %>
                <.link
                  navigate={path}
                  class={nav_link_class(@current_page, key)}
                >
                  <%= title %>
                </.link>
              <% end %>
            </div>
          </div>
          
          <!-- Mobile menu button -->
          <div class="sm:hidden flex items-center">
            <button
              type="button"
              class="inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-gray-500 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500"
              aria-controls="mobile-menu"
              aria-expanded="false"
              x-data="{ open: false }"
              @click="open = !open"
            >
              <span class="sr-only">Open main menu</span>
              <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
              </svg>
            </button>
          </div>
        </div>
      </div>
      
      <!-- Mobile menu -->
      <div class="sm:hidden" id="mobile-menu" x-data="{ open: false }" x-show="open">
        <div class="pt-2 pb-3 space-y-1">
          <%= for {path, title, key} <- nav_items() do %>
            <.link
              navigate={path}
              class={mobile_nav_link_class(@current_page, key)}
            >
              <%= title %>
            </.link>
          <% end %>
        </div>
      </div>
    </nav>
    """
  end

  defp nav_items do
    [
      {"/", "Home", :map_demo},
      {"/stage1", "Stage 1: Basics", :stage1},
      {"/stage2", "Stage 2: Groups", :stage2},
      {"/stage3", "Stage 3: Themes", :stage3},
      {"/stage4", "Stage 4: Builder", :stage4},
      {"/map", "Machine Map", :machine_map}
    ]
  end

  defp nav_link_class(current_page, page_key) do
    base_class = "inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium transition-colors"
    
    if current_page == page_key do
      "#{base_class} border-blue-500 text-gray-900"
    else
      "#{base_class} border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"
    end
  end

  defp mobile_nav_link_class(current_page, page_key) do
    base_class = "block pl-3 pr-4 py-2 border-l-4 text-base font-medium transition-colors"
    
    if current_page == page_key do
      "#{base_class} bg-blue-50 border-blue-500 text-blue-700"
    else
      "#{base_class} border-transparent text-gray-600 hover:text-gray-800 hover:bg-gray-50 hover:border-gray-300"
    end
  end
end