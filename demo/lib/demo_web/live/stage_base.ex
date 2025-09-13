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
  @callback get_advanced_topics() :: list(map())

  # Optional callbacks with default implementations
  @callback default_example() :: String.t()
  @callback handle_stage_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
              {:noreply, Phoenix.LiveView.Socket.t()}
  @callback stage_theme() :: atom()
  @callback stage_layout() :: atom()
  @callback get_example_theme(String.t()) :: atom()

  @optional_callbacks [
    default_example: 0,
    handle_stage_event: 3,
    stage_theme: 0,
    stage_layout: 0,
    get_example_theme: 1
  ]

  defmacro __using__(_opts) do
    quote do
      @behaviour DemoWeb.Live.StageBase

      use DemoWeb, :live_view

      alias DemoWeb.Helpers.CodeGenerator

      def mount(_params, _session, socket) do
        examples = stage_examples()
        tabs = stage_tabs()

        default_example =
          if function_exported?(__MODULE__, :default_example, 0) do
            default_example()
          else
            # Use first tab key as default
            tabs |> List.first() |> Map.get(:key)
          end

        {:ok,
         assign(socket,
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
        stage_page =
          __MODULE__
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
          layout: stage_layout(),
          get_focused_code: fn example, marker_groups ->
            get_focused_code(
              example,
              marker_groups,
              current_example_description(assigns),
              current_example_code_comment(assigns)
            )
          end,
          current_example_description: current_example_description(assigns),
          current_example_code_comment: current_example_code_comment(assigns)
        })
      end

      # Common helper functions
      defp current_marker_groups(assigns) do
        case Map.get(assigns.examples, String.to_atom(assigns.current_example), []) do
          # Pass nil through to indicate no marker groups
          nil -> nil
          # Support both old format (list of marker groups) and new format (map with metadata)
          %{marker_groups: groups} -> groups
          # Backward compatibility
          groups when is_list(groups) -> groups
          groups -> groups
        end
      end

      defp current_example_description(assigns) do
        case Map.get(assigns.examples, String.to_atom(assigns.current_example), []) do
          nil -> nil
          %{description: description} -> description
          _ -> ""
        end
      end

      defp current_example_code_comment(assigns) do
        case Map.get(assigns.examples, String.to_atom(assigns.current_example), []) do
          nil -> nil
          # Support new format with code comment metadata
          %{code_comment: comment} -> comment
          # No comment for old format
          _ -> nil
        end
      end

      defp count_total_nodes(marker_groups) when is_nil(marker_groups), do: 0

      defp count_total_nodes(marker_groups) do
        Enum.reduce(marker_groups, 0, fn group, acc ->
          nodes = group[:nodes] || []
          acc + length(nodes)
        end)
      end

      defp get_focused_code(
             example,
             marker_groups,
             current_example_description,
             code_comment \\ nil
           ) do
        context = get_context_name(example)

        # Check for per-example theme first, then fall back to stage theme
        theme =
          if function_exported?(__MODULE__, :get_example_theme, 1) do
            apply(__MODULE__, :get_example_theme, [example]) || get_stage_theme()
          else
            get_stage_theme()
          end

        # Check for per-example layout first, then fall back to stage layout
        layout =
          if function_exported?(__MODULE__, :get_example_layout, 1) do
            apply(__MODULE__, :get_example_layout, [example]) || get_stage_layout()
          else
            get_stage_layout()
          end

        CodeGenerator.generate_flymap_code(
          marker_groups,
          theme: theme,
          layout: layout,
          context: context,
          format: :heex,
          code_comment: code_comment,
          example_description: current_example_description
        )
      end

      defp get_stage_theme do
        if function_exported?(__MODULE__, :stage_theme, 0) do
          stage_theme()
        else
          :responsive
        end
      end

      defp get_stage_layout do
        if function_exported?(__MODULE__, :stage_layout, 0) do
          case stage_layout() do
            value -> value
          end
        else
          :side_by_side
        end
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
      # defoverridable [get_context_name: 1]
    end
  end
end
