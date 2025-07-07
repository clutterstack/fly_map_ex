defmodule DemoWeb.Live.StageBase do
  @moduledoc """
  Behaviour for creating standardized stage LiveViews with common patterns.
  
  This behaviour defines the structure and callbacks needed for stage components
  in the FlyMapEx demo application, reducing code duplication and providing
  a consistent interface for authoring new stages.
  """

  # Required callbacks for stage-specific content
  @callback stage_title() :: String.t()
  @callback stage_description() :: String.t()
  @callback stage_examples() :: map()
  @callback stage_tabs() :: list(map())
  @callback stage_navigation() :: %{prev: atom() | nil, next: atom() | nil}
  @callback get_current_description(String.t()) :: String.t()
  @callback get_advanced_topics() :: list(map())

  # Optional callbacks with default implementations
  @callback default_example() :: String.t()
  @callback handle_stage_event(String.t(), map(), Phoenix.LiveView.Socket.t()) :: 
    {:noreply, Phoenix.LiveView.Socket.t()}
  @callback stage_theme() :: atom()
  @callback stage_layout() :: atom()

  @optional_callbacks [default_example: 0, handle_stage_event: 3, stage_theme: 0, stage_layout: 0]

  defmacro __using__(_opts) do
    quote do
      @behaviour DemoWeb.Live.StageBase
      
      use DemoWeb, :live_view
      
      import DemoWeb.Components.StageLayout
      
      alias DemoWeb.Helpers.CodeGenerator

      def mount(_params, _session, socket) do
        examples = stage_examples()
        tabs = stage_tabs()
        default_example = if function_exported?(__MODULE__, :default_example, 0) do
          default_example()
        else
          # Use first tab key as default
          tabs |> List.first() |> Map.get(:key)
        end

        {:ok, assign(socket,
          examples: examples,
          tabs: tabs,
          current_example: default_example
        )}
      end

      def handle_event("switch_example", %{"option" => option}, socket) do
        {:noreply, assign(socket, current_example: option)}
      end

      def handle_event(event, params, socket) do
        if function_exported?(__MODULE__, :handle_stage_event, 3) do
          apply(__MODULE__, :handle_stage_event, [event, params, socket])
        else
          {:noreply, socket}
        end
      end

      def render(assigns) do
        stage_page = __MODULE__
        |> Module.split()
        |> List.last()
        |> String.replace("Live", "")
        |> String.downcase()
        |> String.to_atom()

        # Use function component approach
        DemoWeb.Components.StageLayout.stage_layout(%{
          current_page: stage_page,
          tabs: assigns.tabs,
          current_tab: assigns.current_example,
          title: stage_title(),
          description: stage_description(),
          marker_groups: current_marker_groups(assigns),
          current_example: assigns.current_example,
          examples: assigns.examples,
          advanced_topics: get_advanced_topics(),
          navigation: stage_navigation(),
          get_current_description: &get_current_description/1,
          get_focused_code: &get_focused_code/2
        })
      end

      # Common helper functions
      defp current_marker_groups(assigns) do
        Map.get(assigns.examples, String.to_atom(assigns.current_example), [])
      end

      defp count_total_nodes(marker_groups) do
        Enum.reduce(marker_groups, 0, fn group, acc ->
          nodes = group[:nodes] || []
          acc + length(nodes)
        end)
      end

      defp get_focused_code(example, marker_groups) do
        context = get_context_name(example)
        theme = if function_exported?(__MODULE__, :stage_theme, 0) do
          case stage_theme() do
            nil -> :responsive
            "" -> :responsive
            value -> value
          end
        else
          :responsive
        end
        layout = if function_exported?(__MODULE__, :stage_layout, 0) do
          case stage_layout() do
            nil -> :side_by_side
            "" -> :side_by_side
            value -> value
          end
        else
          :side_by_side
        end
        
        CodeGenerator.generate_flymap_code(
          marker_groups,
          theme: theme,
          layout: layout,
          context: context,
          format: :heex
        )
      end

      defp get_context_name(example) do
        # Default context name extraction
        example
        |> String.replace("_", " ")
        |> String.split()
        |> List.first()
        |> String.downcase()
      end


      # Allow implementations to override these functions
      defoverridable [get_context_name: 1]
    end
  end
end