defmodule Mix.Tasks.Security.Audit do
  @moduledoc """
  Search for known security vulnerabilities in the `mix.lock`.
  """

  @shortdoc "Audit dependencies for known security vulnerabilities."

  use Mix.Task

  alias ElixirSecurityAdvisoryClient, as: Client
  alias ElixirSecurityAdvisoryClient.Query.VulnerablePackages

  alias Mix.Dep.Lock

  def run(_) do
    audit(dependency_versions())
  end

  defp audit([]) do
    Mix.Shell.IO.error("No dependencies found")
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
        Mix.Shell.IO.info("No vulnerabilities found")

      other ->
        Mix.Shell.IO.error("Vulnerabilities found:")

        for {dependency, %{"title" => title, "description" => description}} <- other do
          IO.ANSI.Docs.print_heading("#{dependency} – #{title}", width: width())

          IO.ANSI.Docs.print(description, width: width())
        end

        System.halt(1)
    end
  end

  defp dependency_versions do
    Lock.read()
    |> Enum.map(fn
      {_, {:hex, dep_name, version, _, _, _, _}} ->
        {dep_name, version}

      {dep_name, _} ->
        Mix.Shell.IO.error("Skipping #{dep_name} because it is not installed via hex")

        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp width do
    case :io.columns() do
      {:ok, width} -> min(width, 80)
      {:error, _} -> 80
    end
  end
end
