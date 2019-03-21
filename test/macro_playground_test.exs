defmodule MacroPlaygroundTest do
  use ExUnit.Case
  doctest MacroPlayground

  test "greets the world" do
    assert MacroPlayground.hello() == :world
  end
end
