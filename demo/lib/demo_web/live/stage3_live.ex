defmodule DemoWeb.Stage3Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts
  alias DemoWeb.Components.MapWithCodeComponent
  import DemoWeb.Components.DemoNavigation

  def mount(_params, _session, socket) do
    marker_groups = [
      %{
        nodes: ["sjc", "fra"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["ams", "lhr"],
        style: FlyMapEx.Style.warning(),
        label: "Maintenance Mode"
      }
    ]

    {:ok,
     assign(socket,
       marker_groups: marker_groups,
       selected_theme: :light,
       available_themes: available_themes()
     )}
  end

  def handle_event("select_theme", %{"theme" => theme}, socket) do
    theme_atom = String.to_existing_atom(theme)
    {:noreply, assign(socket, selected_theme: theme_atom)}
  end

  defp available_themes do
    [
      %{
        key: :light,
        name: "Light Theme",
        description: "Classic light background with dark borders"
      },
      %{
        key: :dark,
        name: "Dark Theme",
        description: "Dark background for low-light environments"
      },
      %{
        key: :minimal,
        name: "Minimal Theme",
        description: "Clean white background for presentations"
      },
      %{key: :cool, name: "Cool Theme", description: "Cool blue tones for technical dashboards"},
      %{key: :warm, name: "Warm Theme", description: "Warm earth tones for friendly interfaces"},
      %{
        key: :high_contrast,
        name: "High Contrast",
        description: "Maximum contrast for accessibility"
      },
      %{
        key: :responsive,
        name: "Responsive Theme",
        description: "Adapts to your site's colour scheme"
      }
    ]
  end

  def render(assigns) do
    theme_info = get_theme_info(assigns.selected_theme)
    assigns = assign(assigns, theme_info: theme_info)

    ~H"""
    <.demo_navigation current_page={:stage3} />
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 3: Interactive Theme Demo</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Explore FlyMapEx's built-in themes and see how they transform your map's appearance.
        </p>
      </div>

    <!-- Theme Selector -->
      <div class="mb-8">
        <h2 class="text-xl font-semibold text-gray-700 mb-4">Choose a Theme</h2>
        <div class="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3">
          <div :for={theme <- @available_themes} class="space-y-2">
            <button
              phx-click="select_theme"
              phx-value-theme={theme.key}
              class={[
                "w-full px-3 py-2 text-sm font-medium rounded-lg border transition-all duration-200",
                if(@selected_theme == theme.key,
                  do: "bg-blue-500 text-white border-blue-500 shadow-md",
                  else:
                    "bg-white text-gray-700 border-gray-300 hover:border-blue-300 hover:bg-blue-50"
                )
              ]}
            >
              {theme.name}
            </button>
            <p class="text-xs text-gray-500 text-center px-1">
              {theme.description}
            </p>
          </div>
        </div>
      </div>

      <MapWithCodeComponent.map_with_code
        marker_groups={@marker_groups}
        map_layout={:side_by_side}
        theme={if @selected_theme == :responsive, do: nil, else: @selected_theme}
        background={
          if @selected_theme == :responsive, do: FlyMapEx.Theme.responsive_background(), else: nil
        }
        title={"Map Preview: #{@theme_info.name}"}
      />

    <!-- Theme Properties -->
      <div class="mt-8 bg-blue-50 rounded-lg p-4">
        <h3 class="font-semibold text-blue-900 mb-2">Theme Properties</h3>
        <div class="text-sm text-blue-800 space-y-1">
          <div><span class="font-medium">Use Case:</span> {@theme_info.description}</div>
          <%= if @theme_info.properties do %>
            <div class="mt-2 space-y-1">
              <div :for={{key, value} <- @theme_info.properties}>
                <span class="font-medium capitalize">
                  {String.replace(to_string(key), "_", " ")}:
                </span>
                <span
                  class="inline-block w-4 h-4 ml-2 border border-gray-300 rounded"
                  style={"background-color: #{value}"}
                >
                </span>
                <span class="ml-1 font-mono text-xs">{value}</span>
              </div>
            </div>
          <% end %>
        </div>
      </div>

    <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link navigate="/stage2" class="btn btn-outline">
          ← Stage 2: Multiple Groups
        </.link>
        <.link navigate="/stage4" class="btn btn-primary">
          Stage 4: Custom Styling →
        </.link>
      </div>
    </div>
    """
  end

  defp get_theme_info(theme) do
    base_themes = %{
      light: %{
        name: "Light Theme",
        description:
          "Classic light background with dark borders - perfect for standard web applications",
        properties: %{land: "#888888", ocean: "#aaaaaa", border: "#0f172a"}
      },
      dark: %{
        name: "Dark Theme",
        description: "Dark background for low-light environments and modern dark mode interfaces",
        properties: %{land: "#0f172a", ocean: "#aaaaaa", border: "#334155"}
      },
      minimal: %{
        name: "Minimal Theme",
        description: "Clean white background ideal for presentations and minimalist designs",
        properties: %{land: "#ffffff", ocean: "#aaaaaa", border: "#e5e7eb"}
      },
      cool: %{
        name: "Cool Theme",
        description: "Cool blue tones perfect for technical dashboards and analytical interfaces",
        properties: %{land: "#f1f5f9", ocean: "#aaaaaa", border: "#64748b"}
      },
      warm: %{
        name: "Warm Theme",
        description: "Warm earth tones that create friendly, approachable interfaces",
        properties: %{land: "#fef7ed", ocean: "#aaaaaa", border: "#c2410c"}
      },
      high_contrast: %{
        name: "High Contrast",
        description: "Maximum contrast for accessibility compliance and enhanced readability",
        properties: %{land: "#ffffff", ocean: "#aaaaaa", border: "#000000"}
      },
      responsive: %{
        name: "Responsive Theme",
        description:
          "Adapts automatically to your site's colour scheme using CSS custom properties",
        properties: nil
      }
    }

    Map.get(base_themes, theme, %{name: "Unknown", description: "Unknown theme", properties: nil})
  end
end
