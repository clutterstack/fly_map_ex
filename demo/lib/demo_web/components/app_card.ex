defmodule DemoWeb.Components.AppCard do
  @moduledoc """
  The legend to go with the WorldMap.
  """

  use Phoenix.Component

  require Logger

  @doc """

  Could use this something like this (but I replaced it with built-in legend functionality in FlyMapEx)
   <!-- Machines by App (all from DNS) -->
    <div class="space-y-4">
      <!--  for group <- @marker_groups do -->
      <%= for app <- @available_apps do %>
        <AppCard.app_card_content
          all_instances_data={@all_instances_data}
          marker_groups={@marker_groups}
          app_name={app}
          selected_apps={@selected_apps}
        />
      <% end %>
    </div>
  """

  def app_card_content(
        %{
          all_instances_data: _all_instances_data,
          marker_groups: _marker_groups,
          app_name: app_name,
          selected_apps: selected_apps
        } = assigns
      ) do
    region_string =
      regions_from_app_name(assigns.all_instances_data, app_name)
      |> Enum.map(fn region -> if is_binary(region), do: region, else: region.label end)
      |> Enum.join(", ")

    is_selected = app_name in selected_apps

    assigns =
      assigns
      |> assign(:region_string, region_string)
      |> assign(:is_selected, is_selected)

    ~H"""
    <div
      class={[
        "border rounded-lg p-3 cursor-pointer transition-all duration-200 hover:shadow-md",
        if(@is_selected,
          do: "border-primary bg-primary/10 shadow-sm",
          else: "border-base-300 hover:border-base-content/20"
        )
      ]}
      phx-click="toggle_app"
      phx-value-app={@app_name}
    >
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span
            class={[
              "inline-block w-3 h-3 rounded-full mr-2",
              if(@is_selected, do: "ring-2 ring-primary/30", else: "")
            ]}
            style={"background-color: #{colour_from_app_name(@marker_groups, @app_name)};"}
          >
          </span>
          <h4 class={[
            "font-semibold",
            if(@is_selected, do: "text-primary", else: "text-base-content")
          ]}>
            {@app_name}
          </h4>
        </div>
        <div class="flex items-center gap-2 text-xs text-base-content/60">
          <span>
            {DemoWeb.MachineMapLive.pluralize_machines(
              machs_from_app_name(@all_instances_data, @app_name)
            )}
          </span>
          <span>•</span>
          <span>{@region_string}</span>
          <%= if @is_selected do %>
            <svg class="w-4 h-4 text-primary" fill="currentColor" viewBox="0 0 20 20">
              <path
                fill-rule="evenodd"
                d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                clip-rule="evenodd"
              />
            </svg>
          <% end %>
        </div>
      </div>
    </div>
    """
  end

  defp regions_from_app_name(all_instances_data, app_name) do
    case Map.get(all_instances_data, app_name) do
      {:ok, instances} ->
        instances
        |> Enum.map(&elem(&1, 1))
        |> Enum.uniq()

      nil ->
        []
    end
  end

  defp colour_from_app_name(marker_groups, app_name) do
    group = group_from_app_name(marker_groups, app_name)

    case group do
      nil -> "#ffffffaa"
      _ -> get_style_color(group.style)
    end
  end

  defp get_style_color(style) when is_map(style) do
    # Extract color from the new style format
    Map.get(style, :color, "#888888")
  end

  defp get_style_color(_), do: "#888888"

  defp group_from_app_name(marker_groups, app_name) do
    Enum.find(marker_groups, fn group ->
      Map.get(group, :app_name) == app_name
    end)
  end

  defp machs_from_app_name(all_instances_data, app_name) do
    case Map.get(all_instances_data, app_name) do
      {:ok, instances} ->
        instances

      nil ->
        []
    end
  end
end
