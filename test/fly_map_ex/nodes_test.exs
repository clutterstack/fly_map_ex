defmodule FlyMapEx.NodesTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias FlyMapEx.Nodes

  describe "process_marker_group/1" do
    test "keeps valid nodes, accepts unknown regions with warnings, drops invalid nodes" do
      group = %{
        label: "Example Group",
        nodes: ["ams", "not-a-region", %{coordinates: "oops"}]
      }

      parent = self()

      log =
        capture_log(fn ->
          {:ok, processed_group} = Nodes.process_marker_group(group)
          send(parent, {:processed_group, processed_group})
        end)

      assert_receive {:processed_group, processed_group}

      # Should have 2 nodes: "ams" and "not-a-region" (both region strings succeed now)
      assert [node1, node2] = processed_group.nodes
      assert node1.label == "Amsterdam"
      assert node1.coordinates == {52, 5}
      assert node2.label == "not-a-region"
      assert node2.coordinates == {-190, 0}

      # Unknown region should log a warning
      assert log =~ "FlyMapEx: Unknown region code \"not-a-region\""
      assert log =~ "using placeholder coordinates"

      # Invalid coordinates should still drop the node and log error
      assert log =~ "FlyMapEx: Dropped invalid node %{coordinates: \"oops\"}"
      assert log =~ "reason: :invalid_coordinates"
    end
  end
end
