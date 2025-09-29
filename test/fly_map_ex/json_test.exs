defmodule FlyMapEx.JSONTest do
  use ExUnit.Case, async: true

  alias FlyMapEx.JSON

  test "encode!/1 returns JSON string" do
    encoded = JSON.encode!(%{foo: "bar"})

    assert is_binary(encoded)
    assert encoded =~ "\"foo\""
    assert encoded =~ "\"bar\""
  end
end
