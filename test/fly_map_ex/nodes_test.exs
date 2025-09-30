defmodule FlyMapEx.NodesTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias FlyMapEx.Nodes

  describe "process_marker_group/1" do
    test "drops invalid nodes, keeps valid ones, and logs each failure" do
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

      assert [%{label: label, coordinates: {lat, lng}}] = processed_group.nodes
      assert is_binary(label) and is_number(lat) and is_number(lng)

      assert log =~ "FlyMapEx: Dropped invalid node \"not-a-region\""
      assert log =~ "reason: :unknown_region"
      assert log =~ "FlyMapEx: Dropped invalid node %{coordinates: \"oops\"}"
      assert log =~ "reason: :invalid_coordinates"
    end
  end
end
