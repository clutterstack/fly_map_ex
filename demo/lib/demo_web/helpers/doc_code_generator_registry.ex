defmodule DemoWeb.Helpers.DocCodeGeneratorRegistry do
  @moduledoc """
  Registry for pluggable code generators in the generic documentation system.

  This module allows different library types to register their own code generation
  functions while maintaining a consistent interface for documentation components.
  """

  @doc """
  Register a code generator function for a specific component type.

  ## Examples

      DocCodeGeneratorRegistry.register(:map, &DemoWeb.Helpers.CodeGenerator.generate_flymap_code/2)
      DocCodeGeneratorRegistry.register(:chart, &MyApp.ChartCodeGenerator.generate_chart_code/2)

  """
  def register(component_type, generator_function) do
    :persistent_term.put({__MODULE__, component_type}, generator_function)
  end

  @doc """
  Generate code for a specific component type using the registered generator.

  Returns generated code string or a default message if no generator is registered.

  ## Examples

      DocCodeGeneratorRegistry.generate_code(:map, marker_groups, theme: :dark)
      DocCodeGeneratorRegistry.generate_code(:chart, chart_data, layout: :vertical)

  """
  def generate_code(component_type, examples, opts \\ []) do
    case get_generator(component_type) do
      nil ->
        "# No code generator registered for component type: #{component_type}\n# Register one with DocCodeGeneratorRegistry.register/2"

      generator_function ->
        generator_function.(examples, opts)
    end
  end

  @doc """
  Get the registered code generator function for a component type.

  Returns the function or nil if none is registered.
  """
  def get_generator(component_type) do
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
  Check if a component type has a registered generator.
  """
  def registered?(component_type) do
    get_generator(component_type) != nil
  end

  @doc """
  Initialize default generators for built-in component types.

  This should be called during application startup to register
  the default FlyMapEx code generator.
  """
  def init_defaults do
    register(:map, &DemoWeb.Helpers.CodeGenerator.generate_flymap_code/2)
  end
end