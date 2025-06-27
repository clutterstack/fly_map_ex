defmodule FlyMapEx.AdaptersTest do
  use ExUnit.Case, async: true

  alias FlyMapEx.Adapters

  describe "from_fly_dns_txt/1" do
    test "parses valid DNS TXT record" do
      txt_record = "683d314fdd4d68 yyz,568323e9b54dd8 lhr"
      expected = [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}]

      assert Adapters.from_fly_dns_txt(txt_record) == expected
    end

    test "handles single machine record" do
      txt_record = "683d314fdd4d68 yyz"
      expected = [{"683d314fdd4d68", "yyz"}]

      assert Adapters.from_fly_dns_txt(txt_record) == expected
    end

    test "handles empty string" do
      assert Adapters.from_fly_dns_txt("") == []
    end

    test "handles non-string input" do
      assert Adapters.from_fly_dns_txt(nil) == []
      assert Adapters.from_fly_dns_txt(123) == []
    end
  end

  describe "from_machine_tuples/3" do
    test "converts machine tuples to marker groups" do
      machines = [{"683d314fdd4d68", "yyz"}, {"568323e9b54dd8", "lhr"}, {"abc123", "yyz"}]

      result = Adapters.from_machine_tuples(machines, "Running Machines")

      assert length(result) == 2

      yyz_group = Enum.find(result, fn group -> group.nodes == ["yyz"] end)
      lhr_group = Enum.find(result, fn group -> group.nodes == ["lhr"] end)

      assert yyz_group.label == "Running Machines (2)"
      assert yyz_group.machine_count == 2
      assert is_map(yyz_group.style)

      assert lhr_group.label == "Running Machines (1)"
      assert lhr_group.machine_count == 1
      assert is_map(lhr_group.style)
    end

    test "uses custom style key" do
      machines = [{"683d314fdd4d68", "yyz"}]

      result = Adapters.from_machine_tuples(machines, "Active", :active)

      assert [group] = result
      assert group.nodes == ["yyz"]
      assert group.label == "Active (1)"
      assert group.machine_count == 1
      assert is_map(group.style)
    end

    test "filters out invalid regions" do
      machines = [{"683d314fdd4d68", "yyz"}, {"invalid", ""}, {"test", nil}]

      result = Adapters.from_machine_tuples(machines, "Valid")

      assert [group] = result
      assert group.nodes == ["yyz"]
      assert group.label == "Valid (1)"
      assert group.machine_count == 1
      assert is_map(group.style)
    end

    test "handles empty input" do
      assert Adapters.from_machine_tuples([], "Empty") == []
      assert Adapters.from_machine_tuples(nil, "Nil") == []
    end
  end
end
