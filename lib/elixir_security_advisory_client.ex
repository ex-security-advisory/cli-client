defmodule ElixirSecurityAdvisoryClient do
  @moduledoc false

  alias HTTPoison.Response

  @opaque t :: %__MODULE__{base_url: String.t()}

  @enforce_keys [:base_url]
  defstruct @enforce_keys

  @default_base_url "https://elixir-security-advisory.gigalixirapp.com/v1/graphiql"

  def create do
    case System.get_env("ELIIR_SECURITY_ADVISORY_API_BASE_URL") do
      nil -> %__MODULE__{base_url: @default_base_url}
      base_url -> %__MODULE__{base_url: base_url}
    end
  end

  def request(%__MODULE__{base_url: base_url}, query, variables \\ %{}) do
    %Response{status_code: 200, body: body} =
      HTTPoison.post!(
        base_url,
        Jason.encode!(%{
          query: query,
          variables: variables
        }),
        [
          {"Content-Type", "application/json"},
          {"Accept", "application/json"}
        ]
      )

    Jason.decode!(body)
  end
end
