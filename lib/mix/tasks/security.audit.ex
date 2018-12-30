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
        IO.puts("#{IO.ANSI.green()}No vulnerabilities found#{IO.ANSI.reset()}")

      other ->
        IO.puts("#{IO.ANSI.red()}Vulnerabilities found:#{IO.ANSI.reset()}")
        IO.puts("")

        for {dependency, %{"title" => title, "description" => description}} <- other do
          put_title(dependency, title)

          IO.puts("""

          #{description}

          """)
        end

        System.halt(1)
    end
  end

  defp dependency_versions do
    Mix.Dep.Lock.read()
    |> Enum.map(fn
      {_, {:hex, dep_name, version, _, _, _, _}} ->
        {dep_name, version}

      {dep_name, _} ->
        IO.puts(
          "#{IO.ANSI.yellow()}Skipping #{dep_name} because it is not installed via hex#{
            IO.ANSI.reset()
          }"
        )

        nil
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp put_title(dependency, title) do
    heading = "#{dependency} – #{title}"
    padding = div(width() + String.length(heading), 2)
    heading = heading |> String.pad_leading(padding) |> String.pad_trailing(width())

    IO.puts(IO.ANSI.reverse() <> IO.ANSI.yellow() <> heading <> IO.ANSI.reset())
  end

  defp width() do
    case :io.columns() do
      {:ok, width} -> min(width, 80)
      {:error, _} -> 80
    end
  end
end
