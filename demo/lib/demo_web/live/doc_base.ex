defmodule DemoWeb.Live.DocBase do
  @moduledoc """
  Behaviour for creating standardized documentation LiveViews with common patterns.

  This behaviour defines the structure and callbacks needed for interactive documentation
  components, reducing code duplication and providing a consistent interface for
  authoring new documentation pages across different library types.

  Generalized from the original StageBase to support multiple interactive component types
  beyond just maps.
  """

  # Required callbacks for documentation-specific content
  @callback doc_title() :: String.t()
  @callback doc_description() :: String.t()
  @callback doc_examples() :: map()
  @callback doc_tabs() :: list(map())
  @callback doc_navigation() :: %{prev: atom() | nil, next: atom() | nil}
  @callback doc_component_type() :: atom()

  # Optional callbacks with default implementations
  @callback handle_doc_event(String.t(), map(), Phoenix.LiveView.Socket.t()) ::
              {:noreply, Phoenix.LiveView.Socket.t()}
  @callback doc_theme() :: atom()
  @callback doc_layout() :: atom()
  @callback get_example_theme(String.t()) :: atom()

  @optional_callbacks [
    handle_doc_event: 3,
    doc_theme: 0,
    doc_layout: 0,
    get_example_theme: 1
  ]

  defmacro __using__(_opts) do
    quote do
      @behaviour DemoWeb.Live.DocBase

      use DemoWeb, :live_view

      alias DemoWeb.Helpers.{DocCodeGeneratorRegistry, DocComponentRegistry}

      def mount(_params, _session, socket) do
        examples = doc_examples()
        tabs = doc_tabs()

        # Use first tab key as default
        first_tab = tabs |> List.first() |> Map.get(:key)

        {:ok,
         assign(socket,
           examples: examples,
           tabs: tabs,
           current_example: first_tab
         )}
      end

      def handle_event("switch_example", %{"option" => option}, socket) do
        {:noreply, assign(socket, current_example: option)}
      end

      def handle_event(event, params, socket) do
        if function_exported?(__MODULE__, :handle_doc_event, 3) do
          apply(__MODULE__, :handle_doc_event, [event, params, socket])
        else
          {:noreply, socket}
        end
      end

      def render(assigns) do
        doc_page =
          __MODULE__
          |> Module.split()
          |> List.last()
          |> String.replace("Live", "")
          |> String.downcase()
          |> String.to_atom()

        # Use function component approach
        DemoWeb.Components.DocLayout.doc_layout(%{
          current_page: doc_page,
          tabs: assigns.tabs,
          current_tab: assigns.current_example,
          title: doc_title(),
          description: doc_description(),
          component_type: doc_component_type(),
          examples: current_examples(assigns),
          current_example: assigns.current_example,
          all_examples: assigns.examples,
          navigation: doc_navigation(),
          layout: doc_layout(),
          theme: current_theme(assigns),
          get_focused_code: fn example, examples ->
            get_focused_code(
              example,
              examples,
              current_example_description(assigns),
              current_example_code_comment(assigns)
            )
          end,
          current_example_description: current_example_description(assigns),
          current_example_code_comment: current_example_code_comment(assigns)
        })
      end

      # Common helper functions
      defp current_examples(assigns) do
        case Map.get(assigns.examples, String.to_atom(assigns.current_example), []) do
          # Pass nil through to indicate no examples
          nil -> nil
          # Support both old format (list of marker groups) and new format (map with metadata)
          %{marker_groups: groups} -> groups
          # Backward compatibility for direct examples data
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

      defp current_theme(assigns) do
        # Check for dynamic theme from map_config first
        case Map.get(assigns, :map_config) do
          %{theme: theme} when theme != nil -> theme
          _ ->
            # Fall back to per-example theme, then doc theme
            if function_exported?(__MODULE__, :get_example_theme, 1) do
              apply(__MODULE__, :get_example_theme, [assigns.current_example]) || get_doc_theme()
            else
              get_doc_theme()
            end
        end
      end

      defp count_total_nodes(examples) when is_nil(examples), do: 0

      defp count_total_nodes(examples) when is_list(examples) do
        Enum.reduce(examples, 0, fn group, acc ->
          nodes = group[:nodes] || []
          acc + length(nodes)
        end)
      end

      defp count_total_nodes(_), do: 0

      defp get_focused_code(
             example,
             examples,
             current_example_description,
             code_comment \\ nil
           ) do
        context = get_context_name(example)
        component_type = doc_component_type()

        # Check for per-example theme first, then fall back to doc theme
        theme =
          if function_exported?(__MODULE__, :get_example_theme, 1) do
            apply(__MODULE__, :get_example_theme, [example]) || get_doc_theme()
          else
            get_doc_theme()
          end

        # Check for per-example layout first, then fall back to doc layout
        layout =
          if function_exported?(__MODULE__, :get_example_layout, 1) do
            apply(__MODULE__, :get_example_layout, [example]) || get_doc_layout()
          else
            get_doc_layout()
          end

        # Use the registry-based code generator
        DocCodeGeneratorRegistry.generate_code(
          component_type,
          examples,
          theme: theme,
          layout: layout,
          context: context,
          format: :heex,
          code_comment: code_comment,
          example_description: current_example_description
        )
      end

      defp get_doc_theme do
        if function_exported?(__MODULE__, :doc_theme, 0) do
          doc_theme()
        else
          :responsive
        end
      end

      defp get_doc_layout do
        if function_exported?(__MODULE__, :doc_layout, 0) do
          case doc_layout() do
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