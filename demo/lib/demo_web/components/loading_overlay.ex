defmodule DemoWeb.Components.LoadingOverlay do
  @moduledoc """
  A loading overlay component that displays over content during loading operations.
  
  Provides a semi-transparent overlay with spinner and loading message.
  """
  
  use Phoenix.Component

  @doc """
  Renders a loading overlay that can be positioned over other content.
  
  ## Attributes
  
  * `show` - Boolean indicating whether to show the overlay
  * `message` - Loading message to display (default: "Loading...")
  * `class` - Additional CSS classes for the overlay container
  """
  attr(:show, :boolean, default: false)
  attr(:message, :string, default: "Loading...")
  attr(:class, :string, default: "")
  
  def render(assigns) do
    ~H"""
    <%= if @show do %>
      <div class={[
        "absolute inset-0 bg-base-100/80 backdrop-blur-sm z-10",
        "flex items-center justify-center rounded-lg",
        @class
      ]}>
        <div class="bg-info/10 border border-info/20 rounded-lg p-6">
          <div class="flex items-center gap-3">
            <svg
              class="animate-spin h-6 w-6 text-info"
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
            >
              <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4">
              </circle>
              <path
                class="opacity-75"
                fill="currentColor"
                d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
              >
              </path>
            </svg>
            <div>
              <h3 class="text-info font-semibold"><%= @message %></h3>
              <p class="text-info/80 text-sm">Please wait...</p>
            </div>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end