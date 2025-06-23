defmodule FlyMap.Examples do
  @moduledoc """
  Example usage patterns and demo data for FlyMap components.
  
  Provides sample data and component configurations for testing and demonstration.
  """
  
  use Phoenix.Component
  
  @doc """
  Demo deployment scenario with sample regions.
  """
  def demo_deployment do
    %{
      our_regions: ["sjc"],
      active_regions: ["fra", "ams", "nrt"],
      expected_regions: ["lhr", "ord", "dfw"],
      ack_regions: ["sjc", "fra"]
    }
  end
  
  @doc """
  Global deployment scenario.
  """
  def global_deployment do
    %{
      our_regions: ["sjc"],
      active_regions: ["fra", "ams", "nrt", "syd", "gru"],
      expected_regions: ["lhr", "ord", "dfw", "sin", "bom"],
      ack_regions: ["sjc", "fra", "ams", "nrt"]
    }
  end
  
  @doc """
  Minimal deployment for testing.
  """
  def minimal_deployment do
    %{
      our_regions: ["sjc"],
      active_regions: ["fra"],
      expected_regions: [],
      ack_regions: []
    }
  end
  
  @doc """
  Example component: Basic deployment map
  """
  def basic_map(assigns) do
    deployment = demo_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <FlyMap.render
      our_regions={@our_regions}
      active_regions={@active_regions}
      expected_regions={@expected_regions}
      ack_regions={@ack_regions}
    />
    """
  end
  
  @doc """
  Example component: Dashboard widget
  """
  def dashboard_widget(assigns) do
    deployment = demo_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">Global Deployment Status</h2>
        <FlyMap.render
          our_regions={@our_regions}
          active_regions={@active_regions}
          expected_regions={@expected_regions}
          ack_regions={@ack_regions}
          show_progress={true}
          theme={:dashboard}
        />
        <div class="card-actions justify-end">
          <button class="btn btn-primary btn-sm">View Details</button>
        </div>
      </div>
    </div>
    """
  end
  
  @doc """
  Example component: Monitoring display
  """
  def monitoring_display(assigns) do
    deployment = global_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <div class="space-y-4">
      <div class="stats shadow">
        <div class="stat">
          <div class="stat-title">Total Regions</div>
          <div class="stat-value">{length(@active_regions) + length(@our_regions)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Responding</div>
          <div class="stat-value text-success">{length(@ack_regions)}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Expected</div>
          <div class="stat-value text-warning">{length(@expected_regions)}</div>
        </div>
      </div>
      
      <FlyMap.render
        our_regions={@our_regions}
        active_regions={@active_regions}
        expected_regions={@expected_regions}
        ack_regions={@ack_regions}
        show_progress={true}
        theme={:monitoring}
      />
    </div>
    """
  end
  
  @doc """
  Example component: Dark theme for night mode
  """
  def dark_theme_map(assigns) do
    deployment = demo_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <div class="bg-base-100 p-6 rounded-lg">
      <h3 class="text-lg font-semibold mb-4">Night Mode Deployment Map</h3>
      <FlyMap.render
        our_regions={@our_regions}
        active_regions={@active_regions}
        expected_regions={@expected_regions}
        ack_regions={@ack_regions}
        theme={:dark}
        show_progress={true}
      />
    </div>
    """
  end
  
  @doc """
  Example component: Custom colors and labels
  """
  def custom_styled_map(assigns) do
    deployment = demo_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <FlyMap.render
      our_regions={@our_regions}
      active_regions={@active_regions}
      expected_regions={@expected_regions}
      ack_regions={@ack_regions}
      colors={%{
        our_nodes: "#00ff88",
        active_nodes: "#88ff00",
        expected_nodes: "#ff8800",
        ack_nodes: "#8800ff"
      }}
      legend_config={%{
        our_nodes_label: "Primary Site",
        active_nodes_label: "Secondary Sites",
        expected_nodes_label: "Planned Expansion",
        ack_nodes_label: "Responding Sites"
      }}
    />
    """
  end
  
  @doc """
  Example component: Minimal presentation view
  """
  def presentation_view(assigns) do
    deployment = demo_deployment()
    assigns = assign(assigns, deployment)
    
    ~H"""
    <div class="text-center space-y-6">
      <div>
        <h1 class="text-4xl font-bold">Global Infrastructure</h1>
        <p class="text-xl text-base-content/70">Real-time deployment status across Fly.io regions</p>
      </div>
      
      <FlyMap.render
        our_regions={@our_regions}
        active_regions={@active_regions}
        expected_regions={@expected_regions}
        theme={:presentation}
        class="mx-auto"
      />
      
      <div class="grid grid-cols-2 md:grid-cols-4 gap-4 max-w-2xl mx-auto">
        <div class="stat bg-base-200 rounded-lg">
          <div class="stat-title">Primary</div>
          <div class="stat-value text-blue-500">{length(@our_regions)}</div>
        </div>
        <div class="stat bg-base-200 rounded-lg">
          <div class="stat-title">Active</div>
          <div class="stat-value text-yellow-500">{length(@active_regions)}</div>
        </div>
        <div class="stat bg-base-200 rounded-lg">
          <div class="stat-title">Planned</div>
          <div class="stat-value text-orange-500">{length(@expected_regions)}</div>
        </div>
        <div class="stat bg-base-200 rounded-lg">
          <div class="stat-title">Online</div>
          <div class="stat-value text-purple-500">{length(@ack_regions)}</div>
        </div>
      </div>
    </div>
    """
  end
  
  @doc """
  Generate sample machine data for testing adapters.
  """
  def sample_machines do
    [
      %{"id" => "machine-1-sjc", "region" => "sjc", "status" => "running"},
      %{"id" => "machine-2-fra", "region" => "fra", "status" => "running"},
      %{"id" => "machine-3-ams", "region" => "ams", "status" => "running"},
      %{"id" => "machine-4-nrt", "region" => "nrt", "status" => "stopped"}
    ]
  end
  
  @doc """
  Generate sample acknowledgment data for testing.
  """
  def sample_acknowledgments do
    [
      %{node_id: "machine-1-sjc", status: :ok, timestamp: DateTime.utc_now()},
      %{node_id: "machine-2-fra", status: :ok, timestamp: DateTime.utc_now()},
      %{node_id: "machine-3-ams", status: :timeout, timestamp: DateTime.utc_now()}
    ]
  end
end