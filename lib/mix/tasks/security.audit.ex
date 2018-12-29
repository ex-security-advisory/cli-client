defmodule Mix.Tasks.Security.Audit do
  use Mix.Task

  alias ElixirSecurityAdvisoryClient, as: Client
  alias ElixirSecurityAdvisoryClient.Query.VulnerablePackages

  @shortdoc "Audit dependencies for known security vulnerabilities."

  def run(_) do
    audit(dependency_versions())
  end

  defp audit([]) do
    IO.puts("No dependencies found")
  end

  defp audit(dependencies) when is_list(dependencies) do
    client = Client.create()

    dependencies
    |> Enum.chunk_every(10)
    |> Enum.map(fn chunk ->
      Task.async(fn ->
        %{data: packages} = Client.request(client, VulnerablePackages.query(chunk))
        Enum.to_list(packages)
      end)
    end)
    |> Enum.map(&Task.await/1)
    |> List.flatten()
    |> Enum.map(fn
      {_dependency, %{"edges" => []}} -> nil
      {dependency, %{"edges" => [%{"node" => node}]}} -> {dependency, node}
    end)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] ->
        IO.puts("No vulnerabilities found")

      other ->
        IO.puts("Vulnerabilities found:")
        IO.puts("")

        for {dependency, %{"id" => id, "title" => title, "description" => description}} <- other do
          IO.puts("""
          #{dependency} – #{title} (#{id}):

          #{description}

          """)
        end
    end
  end

  defp dependency_versions do
    Mix.Dep.Lock.read()
    |> Enum.map(fn
      {_, {:hex, dep_name, version, _, _, _, _}} ->
        {dep_name, version}

      {dep_name, _} ->
        IO.puts("Skipping #{dep_name} because it is not installed via hex")
        nil
    end)
    |> Enum.reject(&is_nil/1)
  end
end
