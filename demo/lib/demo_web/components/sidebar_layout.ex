defmodule DemoWeb.Components.SidebarLayout do
  use Phoenix.Component

  @doc """
  Renders a sidebar layout with navigation and main content areas.

  The sidebar contains navigation and supplementary content, while the main area
  displays the primary content (typically maps and interactive elements).

  ## Examples

      <.sidebar_layout>
        <:sidebar>
          <.demo_navigation current_page={:stage1} />
          <div class="p-4">
            <h3>Additional Content</h3>
            <p>Sidebar content here...</p>
          </div>
        </:sidebar>
        <:main>
          <div class="p-6">
            <h1>Main Content</h1>
            <p>Primary content here...</p>
          </div>
        </:main>
      </.sidebar_layout>
  """
  attr :class, :string, default: "", doc: "Additional CSS classes for the layout container"
  attr :sidebar_width, :string, default: "w-64", doc: "Width of the sidebar (Tailwind class)"

  slot :sidebar,
    required: true,
    doc: "Sidebar content including navigation and supplementary info"

  slot :main, required: true, doc: "Main content area"

  def sidebar_layout(assigns) do
    ~H"""
    <div class={["min-h-screen bg-base-200 flex", @class]}>
      <!-- Sidebar -->
      <div class={[
        "hidden lg:flex lg:flex-shrink-0 lg:fixed lg:inset-y-0 lg:left-0 lg:z-50",
        @sidebar_width
      ]}>
        <div class="flex flex-col bg-base-100 border-r border-base-300 w-full">
          {render_slot(@sidebar)}
        </div>
      </div>
      
    <!-- Mobile sidebar overlay -->
      <div
        class="lg:hidden fixed inset-0 z-50 bg-base-content/50 backdrop-blur-sm"
        x-data="{ open: false }"
        x-show="open"
        x-on:click="open = false"
        x-transition:enter="ease-out duration-300"
        x-transition:enter-start="opacity-0"
        x-transition:enter-end="opacity-100"
        x-transition:leave="ease-in duration-200"
        x-transition:leave-start="opacity-100"
        x-transition:leave-end="opacity-0"
        style="display: none;"
      >
        <div
          class={[
            "fixed inset-y-0 left-0 flex flex-col bg-base-100 border-r border-base-300",
            @sidebar_width
          ]}
          x-on:click.stop
          x-transition:enter="ease-out duration-300"
          x-transition:enter-start="transform -translate-x-full"
          x-transition:enter-end="transform translate-x-0"
          x-transition:leave="ease-in duration-200"
          x-transition:leave-start="transform translate-x-0"
          x-transition:leave-end="transform -translate-x-full"
        >
          <!-- Close button -->
          <div class="flex items-center justify-end p-4">
            <button
              type="button"
              class="rounded-md p-2 text-base-content/70 hover:text-base-content hover:bg-base-200"
              x-on:click="open = false"
            >
              <span class="sr-only">Close sidebar</span>
              <svg
                class="h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
              >
                <path stroke-linecap="round" stroke-linejoin="round" d="M6 18L18 6M6 6l12 12" />
              </svg>
            </button>
          </div>

          {render_slot(@sidebar)}
        </div>
      </div>
      
    <!-- Main content -->
      <div class="flex-1 flex flex-col lg:pl-64">
        <!-- Mobile header with menu button -->
        <div class="lg:hidden flex items-center justify-between p-4 bg-base-100 border-b border-base-300">
          <button
            type="button"
            class="rounded-md p-2 text-base-content/70 hover:text-base-content hover:bg-base-200"
            x-data
            x-on:click="document.querySelector('[x-data]').open = true"
          >
            <span class="sr-only">Open sidebar</span>
            <svg
              class="h-6 w-6"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
              />
            </svg>
          </button>
          <h1 class="text-lg font-semibold text-base-content">FlyMapEx Demo</h1>
        </div>
        
    <!-- Main content area -->
        <main class="flex-1 overflow-y-auto">
          {render_slot(@main)}
        </main>
      </div>
    </div>
    """
  end
end
