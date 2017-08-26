defmodule DirectoryTest do
  use ExUnit.Case
  doctest Directory

  test "greets the world" do
    assert Directory.hello() == :world
  end
end
