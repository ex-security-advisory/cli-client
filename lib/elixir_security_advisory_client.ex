defmodule ElixirSecurityAdvisoryClient do
  @moduledoc false

  @opaque t :: %__MODULE__{base_url: String.t()}

  @enforce_keys [:base_url]
  defstruct @enforce_keys

  @default_base_url "https://elixir-security-advisory.gigalixirapp.com/v1/graphql"

  def create do
    case System.get_env("ELIIR_SECURITY_ADVISORY_API_BASE_URL") do
      nil -> %__MODULE__{base_url: @default_base_url}
      base_url -> %__MODULE__{base_url: base_url}
    end
  end

  def request(%__MODULE__{base_url: base_url}, query) do
    :inets.start()
    :ssl.start()

    {:ok, {_, _, body}} =
      :httpc.request(
        :get,
        {to_charlist(base_url <> "?" <> URI.encode_query(%{query: query})),
         [{'accept', 'apllication/ets'}]},
        [],
        body_format: :binary
      )

    :erlang.binary_to_term(body)
  end
end
