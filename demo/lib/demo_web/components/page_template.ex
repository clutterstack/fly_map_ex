defmodule DemoWeb.Components.PageTemplate do
  @moduledoc """
  A reusable template component for non-live pages.
  
  Provides consistent layout, navigation, and theming for static content pages
  like documentation, about pages, and other non-interactive content.
  
  ## Examples
  
      <.page_template current_page={:about}>
        <:title>About FlyMapEx</:title>
        <:description>
          Learn more about the FlyMapEx library and its capabilities for
          displaying interactive world maps with Fly.io region markers.
        </:description>
        <:content>
          <p>Your page content goes here...</p>
        </:content>
      </.page_template>
      
      # With additional sidebar content
      <.page_template current_page={:docs}>
        <:title>Documentation</:title>
        <:description>Complete API reference and usage guides.</:description>
        <:sidebar_extra>
          <div class="p-4">
            <h3 class="font-semibold mb-2">Quick Links</h3>
            <ul class="space-y-1 text-sm">
              <li><a href="#api" class="text-primary hover:underline">API Reference</a></li>
              <li><a href="#examples" class="text-primary hover:underline">Examples</a></li>
            </ul>
          </div>
        </:sidebar_extra>
        <:content>
          <p>Documentation content...</p>
        </:content>
      </.page_template>
  """
  
  use Phoenix.Component
  import DemoWeb.Components.{SidebarLayout, Navigation}
  import DemoWeb.Layouts, only: [flash_group: 1]

  @doc """
  Renders a standardized page template with navigation and content areas.
  
  ## Attributes
  
  * `current_page` (required) - The current page key for navigation highlighting
  * `class` (optional) - Additional CSS classes for the main content container
  
  ## Slots
  
  * `:title` (required) - The page title, displayed as a large heading
  * `:description` (optional) - Page description text, displayed below the title
  * `:content` (required) - The main page content
  * `:sidebar_extra` (optional) - Additional content to display in the sidebar below navigation
  """
  attr :current_page, :atom, required: true, doc: "Current page key for navigation"
  attr :class, :string, default: "", doc: "Additional CSS classes for main content"
  attr :flash, :map, default: %{}, doc: "Flash messages"
  
  slot :title, required: true, doc: "Page title"
  slot :description, doc: "Page description (optional)"
  slot :content, required: true, doc: "Main page content"
  slot :sidebar_extra, doc: "Additional sidebar content (optional)"

  def page_template(assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    
    <!-- Top navigation for mobile/narrow screens -->
    <div class="lg:hidden">
      <.navigation layout={:topbar} current_page={@current_page} />
    </div>

    <.sidebar_layout>
      <:sidebar>
        <!-- Sidebar navigation for wide screens -->
        <div class="hidden lg:block h-full">
          <.navigation layout={:sidebar} current_page={@current_page} />
        </div>
        
        <!-- Additional sidebar content if provided -->
        <%= if @sidebar_extra != [] do %>
          <div class="hidden lg:block border-t border-base-300">
            {render_slot(@sidebar_extra)}
          </div>
        <% end %>
      </:sidebar>

      <:main>
        <div class={["w-full p-8", @class]}>
          <!-- Page Title -->
          <h1 class="text-[2rem] mt-4 font-semibold leading-10 tracking-tighter text-balance">
            {render_slot(@title)}
          </h1>
          
          <!-- Page Description (optional) -->
          <%= if @description != [] do %>
            <div class="mt-4 leading-7 text-base-content/70">
              {render_slot(@description)}
            </div>
          <% end %>
          
          <!-- Main Content -->
          <div class="mt-6">
            {render_slot(@content)}
          </div>
        </div>
      </:main>
    </.sidebar_layout>
    """
  end
end