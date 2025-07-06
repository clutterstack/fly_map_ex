defmodule DemoWeb.Helpers.StageEventHandlers do
  @moduledoc """
  Shared event handling logic for stage LiveViews.
  
  This module provides common event handlers and parameter update logic
  that can be used across different stage implementations.
  """

  @doc """
  Handles switching between examples/tabs.
  """
  def handle_switch_example(socket, option) do
    {:noreply, Phoenix.LiveView.assign(socket, current_example: option)}
  end

  @doc """
  Handles parameter updates for custom styling examples.
  Supports common parameter types like size, animation, glow, and color.
  """
  def handle_param_update(socket, param, value) do
    current_params = socket.assigns[:custom_params] || %{}
    
    updated_params = case param do
      "size" -> 
        case Integer.parse(value) do
          {int_value, ""} -> Map.put(current_params, :size, int_value)
          _ -> current_params
        end
      "animation" -> 
        case value do
          val when val in ["none", "pulse", "fade"] -> 
            Map.put(current_params, :animation, String.to_atom(val))
          _ -> current_params
        end
      "glow" -> 
        Map.put(current_params, :glow, value == "true")
      "color" -> 
        if valid_hex_color?(value) do
          Map.put(current_params, :color, value)
        else
          current_params
        end
      _ -> 
        current_params
    end

    {:noreply, Phoenix.LiveView.assign(socket, custom_params: updated_params)}
  end

  @doc """
  Handles preset application for semantic styling.
  """
  def handle_apply_preset(socket, preset) do
    updated_example = case preset do
      preset when preset in ["operational", "warning", "danger", "inactive"] -> 
        "semantic"
      "automatic" -> 
        "automatic"
      "custom" -> 
        "custom"
      "mixed" -> 
        "mixed"
      _ -> 
        socket.assigns.current_example
    end

    {:noreply, Phoenix.LiveView.assign(socket, current_example: updated_example)}
  end

  @doc """
  Handles theme switching for advanced examples.
  """
  def handle_theme_switch(socket, theme) do
    valid_themes = [:responsive, :light, :dark, :minimal, :cool, :warm, :high_contrast]
    
    updated_theme = if String.to_atom(theme) in valid_themes do
      String.to_atom(theme)
    else
      :responsive
    end

    current_config = socket.assigns[:map_config] || %{}
    updated_config = Map.put(current_config, :theme, updated_theme)

    {:noreply, Phoenix.LiveView.assign(socket, map_config: updated_config)}
  end

  @doc """
  Handles layout switching for layout examples.
  """
  def handle_layout_switch(socket, layout) do
    valid_layouts = [:side_by_side, :stacked, :map_only, :legend_only]
    
    updated_layout = if String.to_atom(layout) in valid_layouts do
      String.to_atom(layout)
    else
      :side_by_side
    end

    current_config = socket.assigns[:map_config] || %{}
    updated_config = Map.put(current_config, :layout, updated_layout)

    {:noreply, Phoenix.LiveView.assign(socket, map_config: updated_config)}
  end

  @doc """
  Handles adding/removing regions for interactive examples.
  """
  def handle_region_toggle(socket, region) do
    current_regions = socket.assigns[:active_regions] || []
    
    updated_regions = if region in current_regions do
      List.delete(current_regions, region)
    else
      [region | current_regions]
    end

    {:noreply, Phoenix.LiveView.assign(socket, active_regions: updated_regions)}
  end

  @doc """
  Handles group visibility toggling for legend examples.
  """
  def handle_group_toggle(socket, group_index) do
    current_visibility = socket.assigns[:group_visibility] || %{}
    
    updated_visibility = case Map.get(current_visibility, group_index) do
      false -> Map.put(current_visibility, group_index, true)
      _ -> Map.put(current_visibility, group_index, false)
    end

    {:noreply, Phoenix.LiveView.assign(socket, group_visibility: updated_visibility)}
  end

  @doc """
  Generic event router that delegates to specific handlers based on event name.
  """
  def route_event(event, params, socket) do
    case event do
      "switch_example" -> 
        handle_switch_example(socket, params["option"])
      "update_param" -> 
        handle_param_update(socket, params["param"], params["value"])
      "apply_preset" -> 
        handle_apply_preset(socket, params["preset"])
      "switch_theme" -> 
        handle_theme_switch(socket, params["theme"])
      "switch_layout" -> 
        handle_layout_switch(socket, params["layout"])
      "toggle_region" -> 
        handle_region_toggle(socket, params["region"])
      "toggle_group" -> 
        case Integer.parse(params["group"]) do
          {index, ""} -> handle_group_toggle(socket, index)
          _ -> {:noreply, socket}
        end
      _ -> 
        {:noreply, socket}
    end
  end

  # Private helper functions

  defp valid_hex_color?(value) do
    Regex.match?(~r/^#[0-9A-Fa-f]{6}$/, value)
  end
end