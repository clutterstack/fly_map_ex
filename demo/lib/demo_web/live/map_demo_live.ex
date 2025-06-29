defmodule DemoWeb.MapDemoLive do
  @moduledoc """

  """

  use Phoenix.LiveView


  alias DemoWeb.Layouts
  alias DemoWeb.Components.LoadingOverlay

  def mount(_params, _session, socket) do

    marker_groups = [
      %{
        nodes: [%{label: "NYC Server", coordinates: {40.7128, -74.0060}}, %{label: "floating server", coordinates: {49, -33}}],
        style: FlyMapEx.Style.primary(),
        label: "Custom Locations"
      }
    ]


    socket =
      socket
      |> assign(:marker_groups, marker_groups)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div class="container mx-auto px-4 py-8">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold text-base-content">FlyMapEx marker demo</h1>
        <Layouts.theme_toggle />
      </div>
      <h2 class="text-xl mb-4 text-base-content">Displaying marker groups however</h2>


    <!-- World Map -->
      <div class="bg-base-100 rounded-lg shadow-lg p-6 mb-6 relative">
        <FlyMapEx.render
          marker_groups={@marker_groups}
          background={FlyMapEx.Theme.responsive_background()}
          class="machine-map"
        />
      </div>
    </div>
    """
  end

  # Helper functions

  @doc """
  Returns a properly pluralized string for machine counts.
  """
  def pluralize_machines(count) when is_integer(count) do
    case count do
      1 -> "1 machine"
      n -> "#{n} machines"
    end
  end

  def pluralize_machines(list) when is_list(list) do
    pluralize_machines(length(list))
  end




  # A group is a map
  #   %{nodes: ["sjc", "fra"], style: FlyMapEx.Style.primary(), label: "Active Regions"},
  #  We could define a function like the following and add it to the list in the marker_groups
  # assign in order to display the Fly.io deployment regions as active markers (the FlyMapEx lib
  # can display them out of the box, though)
  # defp fly_regions_group do
  #   %{
  #     nodes: FlyMapEx.Regions.list(),
  #     style: FlyMapEx.Style.info(size: 4, animated: false),
  #     label: "Fly.io regions"
  #   }
  # end


end
