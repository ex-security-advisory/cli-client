defmodule ElixirSecurityAdvisoryClient.Query.VulnerablePackages do
  @moduledoc false

  def query(dependencies) when is_list(dependencies) do
    fields =
      dependencies
      |> Enum.map(&field_query/1)
      |> Enum.join("\n")

    """
    {
      #{fields}
    }
    """
  end

  defp field_query({dependency, version}) when is_atom(dependency) and is_binary(version) do
    """
      #{dependency}: vulnerabilities(
        first: 1,
        packageName: "#{dependency}",
        affectsVersion: "#{version}"
      ) {
        edges {
          node {
            id
            title
            description
          }
        }
      }
    """
  end
end
