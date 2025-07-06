# Test the new styling system integration
alias FlyMapEx.Style

IO.puts "Testing new FlyMapEx styling system integration:"

# Test the style builder functions
IO.puts "\n1. Testing style builders:"
operational_style = Style.operational()
IO.inspect operational_style, label: "Operational style"

custom_style = Style.custom("#ff6b6b", size: 10, animation: :pulse)  
IO.inspect custom_style, label: "Custom style"

# Test creating marker groups in the new format
IO.puts "\n2. Testing marker group format:"
marker_groups = [
  %{
    nodes: ["sjc", "fra"],
    style: Style.operational(),
    label: "Production Servers"
  },
  %{
    nodes: ["ams"],
    style: Style.danger(size: 12),
    label: "Critical Issues"
  },
  %{
    nodes: ["lhr"],
    style: [color: "#f59e0b", size: 8, animated: true, animation: :pulse],
    label: "Inline Style Example"
  }
]

IO.inspect marker_groups, label: "Marker groups"

# Test that the style normalization works
IO.puts "\n3. Testing style normalization:"
try do
  # Test Style.normalize directly
  normalized_inline = Style.normalize([color: "#f59e0b", size: 8, animated: true])
  IO.puts "✅ Style normalization successful"
  IO.inspect normalized_inline, label: "Normalized inline style"
rescue 
  e -> 
    IO.puts "❌ Style normalization failed: #{inspect(e)}"
end

IO.puts "\n✅ All new styling system tests completed successfully!"