defmodule FlyMapEx.ComponentTest do
  use ExUnit.Case, async: true
  
  # Test module that exposes the private functions for testing
  defmodule TestHelper do
    # Copy the private functions we want to test
    def add_group_label_if_needed(group) do
      if Map.has_key?(group, :group_label) do
        group
      else
        case Map.get(group, :label) do
          nil -> 
            # Generate default label if missing
            default_label = generate_default_label(group)
            group
            |> Map.put(:label, default_label)
            |> Map.put(:group_label, default_label)
          label -> 
            Map.put(group, :group_label, label)
        end
      end
    end

    def generate_default_label(group) do
      cond do
        # If we have nodes, create label based on count
        Map.has_key?(group, :nodes) and not is_nil(Map.get(group, :nodes)) ->
          node_count = length(Map.get(group, :nodes, []))
          case node_count do
            0 -> "Empty Group"
            1 -> "Single Node"
            count -> "#{count} Nodes"
          end
        
        # If we have a style, use it to generate label
        Map.has_key?(group, :style) ->
          style_name = 
            case Map.get(group, :style) do
              atom when is_atom(atom) -> 
                atom |> to_string() |> String.replace("_", " ") |> String.capitalize()
              _ -> 
                "Styled Group"
            end
          style_name
        
        # Fallback to generic label
        true -> "Marker Group"
      end
    end
  end
  
  describe "default label generation" do
    test "generates node count labels for groups with nodes" do
      group1 = %{nodes: ["sjc", "fra", "lhr"], style: :primary}
      group2 = %{nodes: ["sjc"], style: :secondary}
      group3 = %{nodes: [], style: :warning}
      
      result1 = TestHelper.add_group_label_if_needed(group1)
      result2 = TestHelper.add_group_label_if_needed(group2)
      result3 = TestHelper.add_group_label_if_needed(group3)
      
      assert result1.label == "3 Nodes"
      assert result1.group_label == "3 Nodes"
      
      assert result2.label == "Single Node"
      assert result2.group_label == "Single Node"
      
      assert result3.label == "Empty Group"
      assert result3.group_label == "Empty Group"
    end
    
    test "generates style-based labels for groups with only styles" do
      group1 = %{style: :active}
      group2 = %{style: :very_important}
      group3 = %{style: :warning_level}
      
      result1 = TestHelper.add_group_label_if_needed(group1)
      result2 = TestHelper.add_group_label_if_needed(group2)
      result3 = TestHelper.add_group_label_if_needed(group3)
      
      assert result1.label == "Active"
      assert result1.group_label == "Active"
      
      assert result2.label == "Very important"
      assert result2.group_label == "Very important"
      
      assert result3.label == "Warning level"
      assert result3.group_label == "Warning level"
    end
    
    test "generates fallback label for minimal groups" do
      group = %{}
      
      result = TestHelper.add_group_label_if_needed(group)
      
      assert result.label == "Marker Group"
      assert result.group_label == "Marker Group"
    end
    
    test "preserves existing labels when provided" do
      group1 = %{nodes: ["sjc", "fra"], style: :primary, label: "My Custom Label"}
      group2 = %{nodes: ["ams"], style: :secondary, label: "Another Label"}
      
      result1 = TestHelper.add_group_label_if_needed(group1)
      result2 = TestHelper.add_group_label_if_needed(group2)
      
      assert result1.label == "My Custom Label"
      assert result1.group_label == "My Custom Label"
      
      assert result2.label == "Another Label"
      assert result2.group_label == "Another Label"
    end
    
    test "preserves existing group_label when provided" do
      group = %{nodes: ["sjc"], style: :primary, group_label: "custom-group-id"}
      
      result = TestHelper.add_group_label_if_needed(group)
      
      # Should preserve the existing group_label and not generate a label
      assert Map.get(result, :label) == nil  # No label should be generated
      assert result.group_label == "custom-group-id"
    end
    
    test "handles mixed scenarios with some groups having labels and others not" do
      group1 = %{nodes: ["sjc", "fra"], style: :primary, label: "Production"}
      group2 = %{nodes: ["ams"], style: :secondary}
      group3 = %{style: :warning}
      group4 = %{}
      
      result1 = TestHelper.add_group_label_if_needed(group1)
      result2 = TestHelper.add_group_label_if_needed(group2)
      result3 = TestHelper.add_group_label_if_needed(group3)
      result4 = TestHelper.add_group_label_if_needed(group4)
      
      # First group has explicit label
      assert result1.label == "Production"
      assert result1.group_label == "Production"
      
      # Second group gets default node count label
      assert result2.label == "Single Node"
      assert result2.group_label == "Single Node"
      
      # Third group gets style-based label
      assert result3.label == "Warning"
      assert result3.group_label == "Warning"
      
      # Fourth group gets fallback label
      assert result4.label == "Marker Group"
      assert result4.group_label == "Marker Group"
    end
  end
  
  describe "edge cases" do
    test "handles groups with nil nodes" do
      group = %{nodes: nil, style: :primary}
      
      result = TestHelper.add_group_label_if_needed(group)
      
      # Should get style-based label since nodes is nil
      assert result.label == "Primary"
      assert result.group_label == "Primary"
    end
    
    test "handles groups with non-atom styles" do
      group = %{style: "custom_style"}
      
      result = TestHelper.add_group_label_if_needed(group)
      
      # Should get "Styled Group" for non-atom styles
      assert result.label == "Styled Group"
      assert result.group_label == "Styled Group"
    end
    
    test "handles groups with both nodes and style preference" do
      # When both nodes and style are present, nodes should take precedence
      group = %{nodes: ["sjc", "fra"], style: :primary}
      
      result = TestHelper.add_group_label_if_needed(group)
      
      assert result.label == "2 Nodes"
      assert result.group_label == "2 Nodes"
    end
    
    test "handles empty string and whitespace labels" do
      group1 = %{nodes: ["sjc"], label: ""}
      group2 = %{nodes: ["sjc"], label: "   "}
      
      result1 = TestHelper.add_group_label_if_needed(group1)
      result2 = TestHelper.add_group_label_if_needed(group2)
      
      # Empty and whitespace strings should be preserved as labels
      assert result1.label == ""
      assert result1.group_label == ""
      
      assert result2.label == "   "
      assert result2.group_label == "   "
    end
  end
  
  describe "generate_default_label/1 directly" do
    test "generates correct node count labels" do
      assert TestHelper.generate_default_label(%{nodes: []}) == "Empty Group"
      assert TestHelper.generate_default_label(%{nodes: ["sjc"]}) == "Single Node"
      assert TestHelper.generate_default_label(%{nodes: ["sjc", "fra"]}) == "2 Nodes"
      assert TestHelper.generate_default_label(%{nodes: ["sjc", "fra", "lhr", "ams", "nrt"]}) == "5 Nodes"
    end
    
    test "generates correct style-based labels" do
      assert TestHelper.generate_default_label(%{style: :active}) == "Active"
      assert TestHelper.generate_default_label(%{style: :primary}) == "Primary"
      assert TestHelper.generate_default_label(%{style: :very_important}) == "Very important"
      assert TestHelper.generate_default_label(%{style: :warning_level_high}) == "Warning level high"
    end
    
    test "handles non-atom styles" do
      assert TestHelper.generate_default_label(%{style: "custom"}) == "Styled Group"
      assert TestHelper.generate_default_label(%{style: %{color: "red"}}) == "Styled Group"
    end
    
    test "generates fallback label for empty groups" do
      assert TestHelper.generate_default_label(%{}) == "Marker Group"
      assert TestHelper.generate_default_label(%{other_key: "value"}) == "Marker Group"
    end
    
    test "prefers nodes over style when both present" do
      group = %{nodes: ["sjc", "fra"], style: :primary}
      assert TestHelper.generate_default_label(group) == "2 Nodes"
    end
    
    test "handles nil nodes gracefully" do
      group = %{nodes: nil, style: :primary}
      assert TestHelper.generate_default_label(group) == "Primary"
    end
  end
end