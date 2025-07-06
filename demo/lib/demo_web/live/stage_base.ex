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

  @optional_callbacks [default_example: 0, handle_stage_event: 3]

  defmacro __using__(_opts) do
    quote do
      @behaviour DemoWeb.Live.StageBase
      
      use DemoWeb, :live_view
      
      import DemoWeb.Components.DemoNavigation
      import DemoWeb.Components.InteractiveControls
      import DemoWeb.Components.ProgressiveDisclosure
      import DemoWeb.Components.SidebarLayout
      import DemoWeb.Components.SidebarNavigation
      
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
          handle_stage_event(event, params, socket)
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

        nav = stage_navigation()
        
        ~H"""
        <.demo_navigation current_page={stage_page} />
        <.sidebar_layout>
          <:sidebar>
            <.sidebar_navigation current_page={stage_page} tabs={@tabs} current_tab={@current_example} />
          </:sidebar>

          <:main>
            <div class="container mx-auto p-8">
              <!-- Stage Title & Progress -->
              <div class="mb-8">
                <div class="flex justify-between items-center mb-4">
                  <h1 class="text-3xl font-bold text-base-content"><%= stage_title() %></h1>
                </div>
                <p class="text-base-content/70 mb-6">
                  <%= stage_description() %>
                </p>
              </div>

              <!-- Full Width Map (Above the Fold) -->
              <div class="mb-8 p-6 bg-base-200 rounded-lg">
                <FlyMapEx.render
                  marker_groups={current_marker_groups(assigns)}
                  theme={:responsive}
                  layout={:side_by_side}
                />
              </div>

              <!-- Side-by-Side: Tabbed Info Panel & Code Examples -->
              <div class="grid grid-cols-1 lg:grid-cols-2 gap-8 mb-8">
                <!-- Tabbed Info Panel -->
                <div>
                  <.tabbed_info_panel
                    tabs={@tabs}
                    current={@current_example}
                    event="switch_example"
                    show_tabs={false}
                  />
                </div>

                <!-- Code Examples Panel -->
                <div>
                  <div class="bg-base-100 border border-base-300 rounded-lg overflow-hidden">
                    <div class="bg-base-200 px-4 py-3 border-b border-base-300">
                      <h3 class="font-semibold text-base-content">Code Example</h3>
                    </div>
                    <div class="p-4">
                      <pre class="text-sm text-base-content overflow-x-auto bg-base-200 p-3 rounded"><code><%= get_focused_code(@current_example, current_marker_groups(assigns)) %></code></pre>
                    </div>

                    <!-- Quick Stats -->
                    <div class="bg-primary/10 border-t border-base-300 px-4 py-3">
                      <div class="text-sm text-primary">
                        <strong>Current Configuration:</strong> <%= get_current_description(@current_example) %> •
                        <%= length(current_marker_groups(assigns)) %> groups •
                        <%= count_total_nodes(current_marker_groups(assigns)) %> nodes
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              <!-- Progressive Disclosure for Advanced Topics -->
              <.learn_more_section
                topics={get_advanced_topics()}
              />

              <!-- Navigation -->
              <div class="mt-8 flex justify-between">
                <%= if nav.prev do %>
                  <.link navigate={~p"/#{nav.prev}"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
                    <%= get_prev_label(nav.prev) %>
                  </.link>
                <% else %>
                  <.link navigate={~p"/"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
                    ← Back to Home
                  </.link>
                <% end %>
                
                <%= if nav.next do %>
                  <.link navigate={~p"/#{nav.next}"} class="inline-block bg-primary text-primary-content px-6 py-2 rounded-lg hover:bg-primary/80 transition-colors">
                    <%= get_next_label(nav.next) %>
                  </.link>
                <% else %>
                  <div></div>
                <% end %>
              </div>
            </div>
          </:main>
        </.sidebar_layout>
        """
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
        CodeGenerator.generate_flymap_code(
          marker_groups,
          theme: :responsive,
          layout: :side_by_side,
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

      defp get_prev_label(stage) do
        case stage do
          :stage1 -> "← Stage 1: Defining Marker Groups"
          :stage2 -> "← Stage 2: Styling Markers"
          :stage3 -> "← Stage 3: Map Themes"
          :stage4 -> "← Stage 4: Advanced Features"
          _ -> "← Previous"
        end
      end

      defp get_next_label(stage) do
        case stage do
          :stage1 -> "Next: Stage 1 - Defining Marker Groups →"
          :stage2 -> "Next: Stage 2 - Styling Markers →"
          :stage3 -> "Next: Stage 3 - Map Themes →"
          :stage4 -> "Next: Stage 4 - Advanced Features →"
          _ -> "Next →"
        end
      end

      # Allow implementations to override these functions
      defoverridable [get_context_name: 1]
    end
  end
end