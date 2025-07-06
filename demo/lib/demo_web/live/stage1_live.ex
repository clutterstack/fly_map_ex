defmodule DemoWeb.Stage1Live do
  use DemoWeb, :live_view

  import DemoWeb.Components.DemoNavigation
  import DemoWeb.Components.InteractiveControls
  import DemoWeb.Components.ProgressiveDisclosure
  import DemoWeb.Components.SidebarLayout
  import DemoWeb.Components.SidebarNavigation
  
  alias DemoWeb.Helpers.CodeGenerator


  def mount(_params, _session, socket) do
    # Define the progressive examples according to the plan
    examples = %{
      single_coordinates: [
        %{
          nodes: [%{coordinates: {37.7749, -122.4194}, label: "San Francisco"}],
          label: "Single Node"
        }
      ],
      single_region: [
        %{
          nodes: ["sjc"],
          label: "Single Server"
        }
      ],
      multiple_nodes: [
        %{
          nodes: ["sjc", "fra", "ams", "lhr"],
          label: "Global Deployment"
        }
      ],
      multiple_groups: [
        %{
          nodes: ["sjc", "fra"],
          label: "Production Servers"
        },
        %{
          nodes: ["ams", "lhr"],
          label: "Staging Environment"
        }
      ]
    }

    # Tab content for the new tabbed interface
    tabs = [
      %{
        key: "library_intro",
        label: "About",
        content: get_intro_content()
      },
       %{
        key: "single_coordinates",
        label: "Coordinates",
        content: get_coordinates_content()
      },
      %{
        key: "single_region",
        label: "Fly Regions",
        content: get_region_content()
      },
      %{
        key: "multiple_nodes",
        label: "Multiple",
        content: get_multiple_content()
      },
      %{
        key: "multiple_groups",
        label: "Groups",
        content: get_groups_content()
      }
    ]

    {:ok, assign(socket,
      examples: examples,
      tabs: tabs,
      current_example: "single_coordinates"
    )}
  end

  def handle_event("switch_example", %{"option" => option}, socket) do
    {:noreply, assign(socket, current_example: option)}
  end

  defp current_marker_groups(assigns) do
    Map.get(assigns.examples, String.to_atom(assigns.current_example), [])
  end

  def render(assigns) do
    ~H"""
    <.demo_navigation current_page={:stage1} />
        <.sidebar_layout>
      <:sidebar>
        <.sidebar_navigation current_page={:stage1} tabs={@tabs} current_tab={@current_example} />
      </:sidebar>

      <:main>



    <div class="container mx-auto p-8">
      <!-- Stage Title & Progress -->
      <div class="mb-8">
        <div class="flex justify-between items-center mb-4">
          <h1 class="text-3xl font-bold text-base-content">Stage 1: Defining Marker Groups</h1>
        </div>
        <p class="text-base-content/70 mb-6">
          Learn the fundamental data structure and syntax options for FlyMapEx marker groups.
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
        <.link navigate={~p"/"} class="inline-block bg-neutral text-neutral-content px-6 py-2 rounded-lg hover:bg-neutral/80 transition-colors">
          ← Back to Home
        </.link>
        <.link navigate={~p"/stage2"} class="inline-block bg-primary text-primary-content px-6 py-2 rounded-lg hover:bg-primary/80 transition-colors">
          Next: Stage 2 - Styling Markers →
        </.link>
      </div>
    </div>
              </:main>
    </.sidebar_layout>

    """
  end

  # Tab content creation functions
  defp get_intro_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-base-content mb-2">About FlyMapEx</h4>
        <p class="text-sm text-base-content/70 mb-3">
          An over-engineered library for putting markers on a simple map.
        </p>
      </div>

      <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
        <h5 class="font-medium text-primary mb-2">Coordinate Format</h5>
        <div class="space-y-2 text-sm">
          <div>
            <strong>Latitude:</strong> North/South position (-90 to 90)
          </div>
          <div>
            <strong>Longitude:</strong> East/West position (-180 to 180)
          </div>
          <div>
            <strong>Example:</strong> <code class="bg-base-100 px-1 rounded">{37.7749, -122.4194}</code> for San Francisco
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-base-content mb-2">When to Use</h5>
        <ul class="text-sm text-base-content/70 space-y-1">
          <li>• Custom locations not covered by Fly.io regions</li>
          <li>• Office locations, data centres, or business sites</li>
          <li>• Precise geographic mapping requirements</li>
          <li>• Integration with external coordinate data</li>
        </ul>
      </div>

      <div class="bg-base-200 border border-base-300 rounded-lg p-3">
        <p class="text-xs text-base-content/70">
          <strong>Pro Tip:</strong> Use WGS84 coordinates (standard GPS format). FlyMapEx automatically transforms them to map projection.
        </p>
      </div>
    </div>
    """
  end

  defp get_coordinates_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-base-content mb-2">Custom Coordinates</h4>
        <p class="text-sm text-base-content/70 mb-3">
          Use exact latitude and longitude coordinates for precise placement anywhere on the map.
        </p>
      </div>

      <div class="bg-primary/10 border border-primary/20 rounded-lg p-4">
        <h5 class="font-medium text-primary mb-2">Coordinate Format</h5>
        <div class="space-y-2 text-sm">
          <div>
            <strong>Latitude:</strong> North/South position (-90 to 90)
          </div>
          <div>
            <strong>Longitude:</strong> East/West position (-180 to 180)
          </div>
          <div>
            <strong>Example:</strong> <code class="bg-base-100 px-1 rounded">{37.7749, -122.4194}</code> for San Francisco
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-base-content mb-2">When to Use</h5>
        <ul class="text-sm text-base-content/70 space-y-1">
          <li>• Custom locations not covered by Fly.io regions</li>
          <li>• Office locations, data centres, or business sites</li>
          <li>• Precise geographic mapping requirements</li>
          <li>• Integration with external coordinate data</li>
        </ul>
      </div>

      <div class="bg-base-200 border border-base-300 rounded-lg p-3">
        <p class="text-xs text-base-content/70">
          <strong>Pro Tip:</strong> Use WGS84 coordinates (standard GPS format). FlyMapEx automatically transforms them to map projection.
        </p>
      </div>
    </div>
    """
  end

  defp get_region_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-base-content mb-2">Fly.io Region Codes</h4>
        <p class="text-sm text-base-content/70 mb-3">
          Use three-letter region codes that automatically resolve to exact coordinates for Fly.io infrastructure.
        </p>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-4">
        <h5 class="font-medium text-success mb-2">Popular Regions</h5>
        <div class="grid grid-cols-2 gap-2 text-sm">
          <div class="flex items-center space-x-2">
            <code class="bg-base-100 px-1 rounded text-xs">"sjc"</code>
            <span class="text-success">San Jose, US</span>
          </div>
          <div class="flex items-center space-x-2">
            <code class="bg-base-100 px-1 rounded text-xs">"fra"</code>
            <span class="text-success">Frankfurt, DE</span>
          </div>
          <div class="flex items-center space-x-2">
            <code class="bg-base-100 px-1 rounded text-xs">"lhr"</code>
            <span class="text-success">London, UK</span>
          </div>
          <div class="flex items-center space-x-2">
            <code class="bg-base-100 px-1 rounded text-xs">"nrt"</code>
            <span class="text-success">Tokyo, JP</span>
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-base-content mb-2">Benefits</h5>
        <ul class="text-sm text-base-content/70 space-y-1">
          <li>• Automatically validated region codes</li>
          <li>• Smaller bundle size than coordinates</li>
          <li>• Perfect for Fly.io infrastructure mapping</li>
          <li>• Easy to remember and type</li>
        </ul>
      </div>

      <div class="bg-warning/10 border border-warning/20 rounded-lg p-3">
        <p class="text-xs text-warning">
          <strong>Special Case:</strong> Use <code class="bg-base-100 px-1 rounded">"dev"</code> for development environments - maps to Seattle coordinates.
        </p>
      </div>
    </div>
    """
  end

  defp get_multiple_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-base-content mb-2">Multiple Nodes in One Group</h4>
        <p class="text-sm text-base-content/70 mb-3">
          Combine multiple nodes under a single label and styling for logical organization.
        </p>
      </div>

      <div class="bg-secondary/10 border border-secondary/20 rounded-lg p-4">
        <h5 class="font-medium text-secondary mb-2">Array of Nodes</h5>
        <div class="space-y-2 text-sm">
          <div>
            <strong>Simple List:</strong> <code class="bg-base-100 px-1 rounded">["sjc", "fra", "ams"]</code>
          </div>
          <div>
            <strong>Mixed Types:</strong> Can combine region codes and coordinates
          </div>
          <div>
            <strong>Shared Properties:</strong> All nodes inherit group label and styling
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-base-content mb-2">Use Cases</h5>
        <ul class="text-sm text-base-content/70 space-y-1">
          <li>• Global deployment across multiple regions</li>
          <li>• Load-balanced services in multiple zones</li>
          <li>• Geographic redundancy planning</li>
          <li>• Service mesh or CDN endpoints</li>
        </ul>
      </div>

      <div class="bg-primary/10 border border-primary/20 rounded-lg p-3">
        <p class="text-xs text-primary">
          <strong>Best Practice:</strong> Group related nodes together (e.g., all production servers, all staging environments).
        </p>
      </div>
    </div>
    """
  end

  defp get_groups_content do
    ~s"""
    <div class="space-y-4">
      <div>
        <h4 class="font-semibold text-base-content mb-2">Multiple Groups</h4>
        <p class="text-sm text-base-content/70 mb-3">
          Organize nodes into distinct groups with different purposes, environments, or statuses.
        </p>
      </div>

      <div class="space-y-3">
        <div class="flex items-start space-x-3 p-3 bg-primary/10 border border-primary/20 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-primary mt-0.5"></div>
          <div>
            <h5 class="font-medium text-primary">Production Servers</h5>
            <p class="text-sm text-primary/80">Critical production infrastructure</p>
          </div>
        </div>

        <div class="flex items-start space-x-3 p-3 bg-success/10 border border-success/20 rounded-lg">
          <div class="w-4 h-4 rounded-full bg-success mt-0.5"></div>
          <div>
            <h5 class="font-medium text-success">Staging Environment</h5>
            <p class="text-sm text-success/80">Pre-production testing servers</p>
          </div>
        </div>
      </div>

      <div>
        <h5 class="font-medium text-base-content mb-2">Grouping Strategies</h5>
        <ul class="text-sm text-base-content/70 space-y-1">
          <li>• <strong>Environment-based:</strong> Production, Staging, Development</li>
          <li>• <strong>Service-based:</strong> API, Database, CDN, Cache</li>
          <li>• <strong>Status-based:</strong> Healthy, Warning, Error, Maintenance</li>
          <li>• <strong>Geographic-based:</strong> US-East, EU-West, Asia-Pacific</li>
        </ul>
      </div>

      <div class="bg-success/10 border border-success/20 rounded-lg p-3">
        <p class="text-xs text-success">
          <strong>Automatic Legend:</strong> Each group automatically appears in the legend with its label and colour.
        </p>
      </div>
    </div>
    """
  end

  # Generate focused code examples for each tab
  defp get_focused_code(example, marker_groups) do
    # Use the shared CodeGenerator for consistent code generation
    CodeGenerator.generate_flymap_code(
      marker_groups,
      theme: :responsive,
      layout: :side_by_side,
      context: get_context_name(example),
      format: :heex
    )
  end
  
  # Helper to get readable context names
  defp get_context_name(example) do
    case example do
      "single_coordinates" -> "coordinates"
      "single_region" -> "region"
      "multiple_nodes" -> "multiple"
      "multiple_groups" -> "groups"
      "library_intro" -> "intro"
      _ -> "example"
    end
  end

  # Helper functions for the template
  defp get_current_description(example) do
    case example do
      "single_coordinates" -> "Single node with custom coordinates"
      "single_region" -> "Single node using Fly.io region code"
      "multiple_nodes" -> "Multiple nodes in one group"
      "multiple_groups" -> "Multiple groups with different purposes"
      _ -> "Unknown example"
    end
  end

  defp count_total_nodes(marker_groups) do
    Enum.reduce(marker_groups, 0, fn group, acc ->
      nodes = group[:nodes] || []
      acc + length(nodes)
    end)
  end


  defp get_advanced_topics do
    [
      %{
        id: "coordinate-systems",
        title: "Understanding Coordinate Systems",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-base-content/80">
            FlyMapEx supports two coordinate systems for maximum flexibility:
          </p>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div>
              <h4 class="font-semibold text-base-content mb-2">WGS84 Geographic Coordinates</h4>
              <ul class="text-sm text-base-content/70 space-y-1">
                <li>• Standard latitude and longitude</li>
                <li>• Range: -90 to 90 (latitude), -180 to 180 (longitude)</li>
                <li>• Example: {37.7749, -122.4194} for San Francisco</li>
                <li>• Use when you need precise custom locations</li>
              </ul>
            </div>
            <div>
              <h4 class="font-semibold text-base-content mb-2">Fly.io Region Codes</h4>
              <ul class="text-sm text-base-content/70 space-y-1">
                <li>• Pre-defined 3-letter codes</li>
                <li>• Examples: "sjc", "fra", "ams", "lhr"</li>
                <li>• Automatically resolved to exact coordinates</li>
                <li>• Use for Fly.io infrastructure mapping</li>
              </ul>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "data-structure",
        title: "Marker Group Data Structure",
        content: ~s"""
        <div class="space-y-4">
          <p class="text-sm text-base-content/80">
            Each marker group follows a consistent structure:
          </p>
          <pre class="bg-base-200 p-4 rounded-lg text-sm"><code>%{
            nodes: [list_of_nodes],    # Required: nodes to display
            style: style_specification, # Optional: visual styling
            label: "Group Name"        # Required: legend label
          }</code></pre>
          <div class="mt-4">
            <h4 class="font-semibold text-base-content mb-2">Node Specifications</h4>
            <div class="space-y-2 text-sm">
              <div>
                <strong>Region Code:</strong> <code class="bg-base-200 px-1 rounded">"sjc"</code>
              </div>
              <div>
                <strong>Custom Node:</strong> <code class="bg-base-200 px-1 rounded">%{coordinates: {lat, lng}, label: "Name"}</code>
              </div>
              <div>
                <strong>Mixed:</strong> <code class="bg-base-200 px-1 rounded">["sjc", %{coordinates: {40.7128, -74.0060}, label: "NYC"}]</code>
              </div>
            </div>
          </div>
        </div>
        """
      },
      %{
        id: "production-tips",
        title: "Production Usage Tips",
        content: ~s"""
        <div class="space-y-4">
          <div>
            <h4 class="font-semibold text-base-content mb-2">Performance Considerations</h4>
            <ul class="text-sm text-base-content/70 space-y-1">
              <li>• Groups with fewer than 20 nodes render efficiently</li>
              <li>• Use region codes when possible for smaller bundle size</li>
              <li>• Consider grouping related nodes for better organization</li>
            </ul>
          </div>
          <div>
            <h4 class="font-semibold text-base-content mb-2">Common Patterns</h4>
            <ul class="text-sm text-base-content/70 space-y-1">
              <li>• <strong>Environment-based:</strong> Production, Staging, Development</li>
              <li>• <strong>Service-based:</strong> API Servers, Databases, CDN</li>
              <li>• <strong>Status-based:</strong> Healthy, Warning, Error</li>
              <li>• <strong>Region-based:</strong> US East, EU West, Asia Pacific</li>
            </ul>
          </div>
        </div>
        """
      }
    ]
  end
end
