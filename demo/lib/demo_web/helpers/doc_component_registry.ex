defmodule DemoWeb.Helpers.DocComponentRegistry do
  @moduledoc """
  Registry for pluggable interactive components in the generic documentation system.

  This module allows different library types to register their interactive components
  while maintaining a consistent rendering interface for documentation layouts.
  """

  use Phoenix.Component

  @doc """
  Register a component function for a specific component type.

  ## Examples

      DocComponentRegistry.register(:map, &FlyMapEx.node_map/1)
      DocComponentRegistry.register(:chart, &MyChartLib.chart/1)

  """
  def register(component_type, component_function) do
    :persistent_term.put({__MODULE__, component_type}, component_function)
  end

  @doc """
  Render a component for a specific component type using the registered function.

  Returns the rendered component or a fallback message if no component is registered.

  ## Examples

      <.render_component component_type={:map} examples={@examples} opts={%{theme: :dark}} />

  """
  attr :component_type, :atom, required: true
  attr :examples, :any, required: true
  attr :opts, :map, default: %{}

  def render_component(assigns) do
    case get_component_function(assigns.component_type) do
      nil ->
        ~H"""
        <div class="p-8 bg-base-200 rounded-lg text-center">
          <p class="text-base-content/70">
            No component registered for type: <%= @component_type %>
          </p>
          <p class="text-sm text-base-content/50 mt-2">
            Register one with DocComponentRegistry.register/2
          </p>
        </div>
        """

      component_function ->
        # Create component assigns by merging examples with opts
        component_assigns = Map.merge(assigns.opts, %{marker_groups: assigns.examples})

        # Call the component function directly
        component_function.(component_assigns)
    end
  end

  @doc """
  Get the registered component function for a component type.

  Returns the function or nil if none is registered.
  """
  def get_component_function(component_type) do
    try do
      :persistent_term.get({__MODULE__, component_type})
    rescue
      ArgumentError -> nil
    end
  end

  @doc """
  List all registered component types.

  Returns a list of atoms representing the registered component types.
  """
  def list_registered_types do
    :persistent_term.get()
    |> Enum.filter(fn {{module, _type}, _function} -> module == __MODULE__ end)
    |> Enum.map(fn {{_module, type}, _function} -> type end)
  end

  @doc """
  Check if a component type has a registered function.
  """
  def registered?(component_type) do
    get_component_function(component_type) != nil
  end

  @doc """
  Initialize default components for built-in component types.

  This should be called during application startup to register
  the default FlyMapEx component.
  """
  def init_defaults do
    register(:map, &FlyMapEx.node_map/1)
  end
end