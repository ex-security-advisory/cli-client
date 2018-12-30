defmodule ElixirSecurityAdvisoryClient.IntegrationTest do
  @moduledoc false

  use ExUnit.Case

  setup_all do
    {_, 0} = System.cmd("mix", ["archive.install", "--force"], stderr_to_stdout: true)
    :ok
  end

  @example_app_dir Application.app_dir(:elixir_security_advisory_client, "priv/test/example_apps")

  @expected_status_codes %{
    "not_vulnerable" => 0,
    "other_sources" => 0,
    "vulnerable" => 1
  }

  @output_dir Application.app_dir(:elixir_security_advisory_client, "priv/test/output")
  @expected_dir Application.app_dir(:elixir_security_advisory_client, "priv/test/expected")

  for dir <- File.ls!(@example_app_dir) do
    @app_dir Path.join(@example_app_dir, dir)
    @app_name dir

    describe "example all #{dir}" do
      test "produces correct output" do
        status_code = @expected_status_codes[@app_name]

        assert {output, ^status_code} =
                 System.cmd("mix", ["security.audit"], cd: @app_dir, stderr_to_stdout: true)

        File.write!(Path.join(@output_dir, @app_name), output)
        assert File.read!(Path.join(@expected_dir, @app_name)) == output
      end
    end
  end
end
