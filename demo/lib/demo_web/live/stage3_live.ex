defmodule DemoWeb.Stage3Live do
  use DemoWeb, :live_view

  alias DemoWeb.Layouts

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

    {:ok, assign(socket, marker_groups: marker_groups)}
  end

  def render(assigns) do
    assigns = assign(assigns, :code_example, """
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

<FlyMapEx.render 
  marker_groups={marker_groups}
  background={FlyMapEx.Theme.responsive_background()}
/>
""")

    ~H"""
    <div class="container mx-auto p-8">
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-gray-800">Stage 3: Themes & Backgrounds</h1>
          <Layouts.theme_toggle />
        </div>
        <p class="text-gray-600 mb-6">
          Showcase visual customization through themes, responsive backgrounds, and DaisyUI integration.
        </p>
      </div>

      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        <!-- Map Display -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">Theme Demo</h2>
          
          <FlyMapEx.render 
            marker_groups={@marker_groups}
            background={FlyMapEx.Theme.responsive_background()}
          />
        </div>

        <!-- Code Example -->
        <div class="space-y-4">
          <h2 class="text-xl font-semibold text-gray-700">Code Example</h2>
          <div class="bg-gray-50 rounded-lg p-4">
            <pre class="text-sm text-gray-800 overflow-x-auto"><code><%= @code_example %></code></pre>
          </div>
        </div>
      </div>

      <!-- Navigation -->
      <div class="mt-8 flex justify-between">
        <.link 
          navigate="/stage2" 
          class="btn btn-outline"
        >
          ← Stage 2: Multiple Groups
        </.link>
        <.link 
          navigate="/stage4" 
          class="btn btn-primary"
        >
          Stage 4: Custom Styling →
        </.link>
      </div>
    </div>
    """
  end
end