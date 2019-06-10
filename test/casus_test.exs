defmodule CasusTest do
  use ExUnit.Case
  doctest Casus

  test "greets the world" do
    assert Casus.hello() == :world
  end
end
