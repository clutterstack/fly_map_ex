defmodule DemoWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use DemoWeb, :html
  import DemoWeb.Components.Navigation

  embed_templates "layouts/*"

  @doc """
  Renders the app layout

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layout.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  attr :current_page, :string, required: true
  attr :class, :string, default: ""
  slot :title, required: true
  slot :sidebar_extra
  slot :description
  # slot :content
  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <.flash_group flash={@flash} />

    <div class="min-h-screen bg-base-200 flex">
      <!-- Sidebar -->
      <div class="hidden lg:flex lg:flex-shrink-0 lg:fixed lg:inset-y-0 lg:left-0 lg:z-50 w-64">
        <div class="flex flex-col bg-base-100 border-r border-base-300 w-full">
          <!-- Sidebar navigation for wide screens -->
          <div class="h-full">
            <.theme_toggle />
            <.navigation layout={:sidebar} current_page={@current_page} />
          </div>

    <!-- Additional sidebar content if provided -->
          <%= if @sidebar_extra != [] do %>
            <div class="border-t border-base-300">
              {render_slot(@sidebar_extra)}
            </div>
          <% end %>
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
          class="fixed inset-y-0 left-0 flex flex-col bg-base-100 border-r border-base-300 w-64"
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

          <div class="h-full">
            <.theme_toggle />
            <.navigation layout={:sidebar} current_page={@current_page} />
          </div>

          <%= if @sidebar_extra != [] do %>
            <div class="border-t border-base-300">
              {render_slot(@sidebar_extra)}
            </div>
          <% end %>
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
              {render_slot(@inner_block)}
            </div>
          </div>
        </main>
      </div>
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
