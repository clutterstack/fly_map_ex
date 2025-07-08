defmodule DemoWeb.Stage4Live do
  @moduledoc """
  Stage 4: Interactive Builder

  This stage demonstrates practical application of FlyMapEx concepts,
  including guided scenarios, freeform building, and code export functionality.
  """

  use DemoWeb.Live.StageBase

  alias DemoWeb.Helpers.{ContentHelpers, StageConfig, CodeGenerator}

  # Required StageBase callbacks

  def stage_title, do: "Stage 4: Interactive Builder"

  def stage_description do
    "Apply your knowledge to build real-world map configurations with guided scenarios, freeform building, and code export."
  end

  def stage_examples do
    %{
      guided: evaluate_scenario_code(get_scenario_code("monitoring")),
      freeform: [],
      export: evaluate_scenario_code(get_scenario_code("monitoring"))
    }
  end

  def stage_tabs do
    [
      %{
        key: "guided",
        label: "Guided Scenarios",
        content: get_guided_content()
      },
      %{
        key: "freeform",
        label: "Freeform Builder",
        content: get_freeform_content()
      },
      %{
        key: "export",
        label: "Export & Integration",
        content: get_export_content()
      }
    ]
  end

  def stage_navigation, do: StageConfig.stage_navigation(:stage4)

  def get_current_description(example) do
    case example do
      "guided" -> "Real-world scenarios with step-by-step guidance"
      "freeform" -> "Custom builder tools (Phase 2 enhancement)"
      "export" -> "Code generation and integration patterns"
      _ -> "Interactive builder tools"
    end
  end

  def get_advanced_topics do
    [
      %{
        id: "scenario-templates",
        title: "Building Scenario Templates",
        content: get_scenario_templates_content()
      },
      %{
        id: "integration-patterns",
        title: "Production Integration Patterns",
        content: get_integration_patterns_content()
      },
      %{
        id: "advanced-customization",
        title: "Advanced Customization Techniques",
        content: get_advanced_customization_content()
      }
    ]
  end

  def default_example, do: "guided"

  def stage_theme, do: :presentation

  def stage_layout, do: :map_only

  # Optional StageBase callbacks

  def handle_stage_event("switch_scenario", %{"option" => scenario}, socket) do
    code_string = get_scenario_code(scenario)
    marker_groups = evaluate_scenario_code(code_string)
    {:noreply, assign(socket, current_scenario: scenario, current_code: code_string) |> update_marker_groups(marker_groups)}
  end

  def handle_stage_event("switch_format", %{"option" => format}, socket) do
    {:noreply, assign(socket, export_format: format)}
  end

  def handle_stage_event(_event, _params, socket) do
    {:noreply, socket}
  end

  # Content generation functions using ContentHelpers

  # Advanced topics content

  defp get_scenario_templates_content do
    [
      ContentHelpers.content_section(
        "Building Scenario Templates",
        "Create reusable templates for common map configurations and use cases."
      ),
      ContentHelpers.ul_with_bold(
        "Template Design Patterns",
        [
          {"Parameterized configs", "Design flexible, reusable configurations"},
          {"Validation systems", "Ensure template consistency and error handling"},
          {"Documentation standards", "Create clear usage guides for template consumers"},
          {"Version management", "Handle template evolution and backwards compatibility"}
        ]
      ),
      ContentHelpers.code_snippet(
        "# Template structure example\ndefmodule MyApp.MapTemplates do\n  def monitoring_template(regions, options \\\\ []) do\n    theme = Keyword.get(options, :theme, :dashboard)\n    [\n      %{nodes: regions.production, style: operational(), label: \"Production\"},\n      %{nodes: regions.staging, style: warning(), label: \"Staging\"}\n    ]\n  end\nend"
      ),
      ContentHelpers.pro_tip(
        "Use parameterized templates to balance flexibility with consistency across your organization.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_integration_patterns_content do
    [
      ContentHelpers.content_section(
        "Production Integration Patterns",
        "Best practices for deploying maps in production Phoenix applications."
      ),
      ContentHelpers.ul_with_bold(
        "Data Loading Strategies",
        [
          {"Dynamic loading", "Efficient strategies for runtime marker group loading"},
          {"Caching systems", "Optimize performance with smart caching approaches"},
          {"Error handling", "Graceful degradation for missing regions or data"},
          {"Real-time updates", "Live data synchronization with Phoenix PubSub"}
        ]
      ),
      ContentHelpers.code_snippet(
        "# Production integration example\ndefmodule MyAppWeb.DashboardLive do\n  def mount(_params, _session, socket) do\n    marker_groups = MyApp.Infrastructure.get_current_status()\n    {:ok, assign(socket, marker_groups: marker_groups)}\n  end\n  \n  def handle_info({:status_update, new_groups}, socket) do\n    {:noreply, assign(socket, marker_groups: new_groups)}\n  end\nend"
      ),
      ContentHelpers.pro_tip(
        "Implement graceful degradation for network failures and missing data to ensure reliable user experiences.",
        type: :production
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_advanced_customization_content do
    [
      ContentHelpers.content_section(
        "Advanced Customization Techniques",
        "Extend FlyMapEx with custom components and behaviors beyond standard configurations."
      ),
      ContentHelpers.ul_with_bold(
        "Customization Areas",
        [
          {"Custom styles", "Create entirely custom marker and map styles"},
          {"Interactive elements", "Add click handlers and hover effects"},
          {"Animation control", "Fine-tune animations for specific use cases"},
          {"Integration hooks", "Connect with external data sources and APIs"}
        ]
      ),
      ContentHelpers.code_snippet(
        "# Custom interactive map\n<FlyMapEx.render\n  marker_groups={@marker_groups}\n  theme={:custom}\n  on_marker_click={&handle_marker_click/1}\n  custom_animations={%{pulse_speed: :fast}}\n/>"
      ),
      ContentHelpers.pro_tip(
        "Start with standard configurations and gradually add customizations as your requirements become clearer.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  # Tab content creation functions using ContentHelpers

  defp get_guided_content do
    [
      ContentHelpers.content_section(
        "Guided Scenarios",
        "Learn by building real-world map configurations with step-by-step guidance. Each scenario demonstrates common patterns and best practices."
      ),
      get_scenario_builder("monitoring", "Monitoring Dashboard", "Track service health across multiple regions with status indicators.", "primary", [
        "Production servers marked as operational",
        "Maintenance windows highlighted with warnings",
        "Clear legend for status interpretation"
      ]),
      get_scenario_builder("deployment", "Deployment Map", "Visualize application rollouts and deployment status across regions.", "success", [
        "Active deployments with animated markers",
        "Completed deployments in stable states",
        "Pending regions awaiting deployment"
      ]),
      get_scenario_builder("status", "Status Board", "Create a comprehensive status overview for incident response and monitoring.", "secondary", [
        "Critical issues highlighted with danger styling",
        "Healthy services marked as operational",
        "Maintenance and acknowledged states"
      ]),
      ContentHelpers.pro_tip(
        "Each scenario builds on concepts from previous stages, combining marker groups, styling, and theming into practical applications.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_freeform_content do
    [
      ContentHelpers.content_section(
        "Freeform Builder",
        "Build custom map configurations from scratch with full creative control. Perfect for unique requirements and experimental designs."
      ),
      ContentHelpers.info_box(
        :primary,
        "Interactive Region Selection",
        [
          "Click regions on the map to build your marker groups dynamically.",
          ContentHelpers.titled_list([
            "Visual region picker with live preview",
            "Drag and drop group organization",
            "Real-time code generation"
          ]),
          ~s(<div class="mt-2 text-xs text-primary/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
        ] |> Enum.join()
      ),
      ContentHelpers.info_box(
        :success,
        "Custom Group Builder",
        [
          "Create marker groups with custom styling and labels.",
          ContentHelpers.titled_list([
            "Add/remove regions with search and autocomplete",
            "Live style customization with sliders and pickers",
            "Group management with reordering and duplication"
          ]),
          ~s(<div class="mt-2 text-xs text-success/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
        ] |> Enum.join()
      ),
      ContentHelpers.info_box(
        :secondary,
        "Live Preview Canvas",
        [
          "See your changes instantly as you build.",
          ContentHelpers.titled_list([
            "Real-time map updates during editing",
            "Side-by-side comparison views",
            "Undo/redo functionality"
          ]),
          ~s(<div class="mt-2 text-xs text-secondary/70"><em>Coming in Phase 2: Enhanced Interactivity</em></div>)
        ] |> Enum.join()
      ),
      ContentHelpers.pro_tip(
        "Use the guided scenarios to explore different configurations. Full freeform building tools will be added in Phase 2 with interactive controls and live editing.",
        type: :warning
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  defp get_export_content do
    [
      ContentHelpers.content_section(
        "Export & Integration",
        "Generate production-ready code in multiple formats for seamless integration into your Phoenix LiveView applications."
      ),
      ContentHelpers.info_box(
        :primary,
        "Export Formats",
        [
          "Choose the format that best fits your integration needs:",
          get_format_buttons(),
          ContentHelpers.titled_list([
            "HEEx: Direct template integration",
            "Elixir: Reusable function modules",
            "JSON: Configuration-driven approach"
          ])
        ] |> Enum.join()
      ),
      ContentHelpers.ul_with_bold(
        "Integration Patterns",
        [
          {"Direct Embed", "Copy HEEx template into your LiveView"},
          {"Function Component", "Create reusable components"},
          {"Configuration Module", "Centralize map configurations"},
          {"Dynamic Loading", "Load configurations from database"}
        ]
      ),
      ContentHelpers.ul_with_bold(
        "Production Considerations",
        [
          {"Performance", "Optimize for rendering speed"},
          {"Maintainability", "Structure for easy updates"},
          {"Scalability", "Handle growing data sets"},
          {"Accessibility", "Ensure inclusive design"}
        ]
      ),
      ContentHelpers.info_box(
        :warning,
        "Copy to Clipboard",
        [
          "Generated code is ready for immediate use:",
          ~s(<div class="mt-2 text-xs text-warning/70"><em>Coming in Phase 2: One-click clipboard integration</em></div>)
        ] |> Enum.join()
      ),
      ContentHelpers.pro_tip(
        "Start with HEEx templates for quick prototyping, then extract to Elixir modules for production applications with multiple maps.",
        type: :best_practice
      ),
      "</div>"
    ]
    |> Enum.join()
  end

  # Helper functions

  defp get_scenario_builder(scenario_key, title, description, color, features) do
    ContentHelpers.info_box(
      String.to_atom(color),
      title,
      [
        description,
        ~s(<button phx-click="switch_scenario" phx-value-option="#{scenario_key}" class="bg-#{color} text-#{color}-content px-3 py-1 rounded text-sm hover:bg-#{color}/80 transition-colors mb-2">Load Scenario</button>),
        ContentHelpers.titled_list(features)
      ] |> Enum.join()
    )
  end

  defp get_format_buttons do
    [
      ~s(<div class="flex gap-2 mb-2">),
      ~s(<button phx-click="switch_format" phx-value-option="heex" class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors">HEEx Template</button>),
      ~s(<button phx-click="switch_format" phx-value-option="elixir" class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors">Elixir Module</button>),
      ~s(<button phx-click="switch_format" phx-value-option="json" class="bg-primary text-primary-content px-3 py-1 rounded text-sm hover:bg-primary/80 transition-colors">JSON Config</button>),
      ~s(</div>)
    ] |> Enum.join()
  end

  # Scenario code generation
  defp get_scenario_code("monitoring") do
    """
    [
      %{
        nodes: ["sjc", "fra", "ams", "lhr"],
        style: FlyMapEx.Style.operational(),
        label: "Production Servers"
      },
      %{
        nodes: ["syd", "nrt"],
        style: FlyMapEx.Style.warning(),
        label: "Maintenance Windows"
      }
    ]
    """
  end

  defp get_scenario_code("deployment") do
    """
    [
      %{
        nodes: ["sjc", "fra"],
        style: FlyMapEx.Style.operational(),
        label: "Deployed v2.1.0"
      },
      %{
        nodes: ["ams", "lhr"],
        style: FlyMapEx.Style.operational(),
        label: "Deploying v2.1.0"
      },
      %{
        nodes: ["syd", "nrt", "dfw"],
        style: FlyMapEx.Style.inactive(),
        label: "Pending Deployment"
      }
    ]
    """
  end

  defp get_scenario_code("status") do
    """
    [
      %{
        nodes: ["sjc", "fra", "ams"],
        style: FlyMapEx.Style.operational(),
        label: "Healthy Services"
      },
      %{
        nodes: ["lhr"],
        style: FlyMapEx.Style.danger(),
        label: "Critical Issues"
      },
      %{
        nodes: ["syd"],
        style: FlyMapEx.Style.warning(),
        label: "Degraded Performance"
      },
      %{
        nodes: ["nrt"],
        style: FlyMapEx.Style.info(),
        label: "Acknowledged Issues"
      }
    ]
    """
  end

  defp get_scenario_code(_), do: "[]"

  # Evaluate scenario code to get marker_groups data
  defp evaluate_scenario_code(code_string) do
    CodeGenerator.evaluate_marker_groups_code(code_string)
  end

  # Helper function to update marker groups based on current tab
  defp update_marker_groups(socket, marker_groups) do
    case socket.assigns.current_example do
      "guided" -> assign(socket, examples: Map.put(socket.assigns.examples, :guided, marker_groups))
      "export" -> assign(socket, examples: Map.put(socket.assigns.examples, :export, marker_groups))
      _ -> socket
    end
  end

  # Override context name for better code generation
  def get_context_name(example) do
    case example do
      "guided" -> "scenario"
      "freeform" -> "builder"
      "export" -> "export"
      _ -> "interactive"
    end
  end
end
