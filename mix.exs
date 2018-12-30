defmodule ElixirSecurityAdvisoryClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_security_advisory_client,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mix, :ssl, :inets]
    ]
  end

  # No Runtime Deps to ensure archive compatibility!
  def deps do
    [
      {:dialyxir, "~> 1.0-rc", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.10", only: :test, runtime: false}
    ]
  end
end
