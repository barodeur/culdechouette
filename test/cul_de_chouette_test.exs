defmodule CulDeChouetteTest do
  use ExUnit.Case
  doctest CulDeChouette

  test "greets the world" do
    assert CulDeChouette.hello() == :world
  end
end
