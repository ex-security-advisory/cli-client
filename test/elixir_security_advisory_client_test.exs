defmodule ElixirSecurityAdvisoryClientTest do
  use ExUnit.Case
  doctest ElixirSecurityAdvisoryClient

  test "greets the world" do
    assert ElixirSecurityAdvisoryClient.hello() == :world
  end
end
