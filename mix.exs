defmodule ElixirSecurityAdvisoryClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_security_advisory_client,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      # No Deps to ensure archive compatibility!
      deps: []
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:mix, :ssl, :inets]
    ]
  end
end
