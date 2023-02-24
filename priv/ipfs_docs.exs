defmodule KuboEx.IpfsDocs do
  # TODO: Implement as custom mix task
  def get_commands(url \\ "https://docs.ipfs.tech/reference/kubo/rpc/") do
    document =
      url
      |> HTTPoison.get!()
      |> Map.get(:body)
      |> Floki.parse_document!()

    document
    |> Floki.find("h2")
    |> Floki.attribute("id")
    |> Enum.filter(&String.starts_with?(&1, "api-v0-"))
    |> Enum.map(&String.replace(&1, "api-v0-", ""))
    |> Enum.map(&String.split(&1, "-"))
    # Maybe regex
  end

  def calc_implemented(commands) do
    import KuboEx.Rpc, warn: false

    atomized = Enum.map(commands, fn command -> command |> Enum.join("_") |> String.to_atom() end)

    implemented = Enum.filter(atomized, &function_exported?(KuboEx.Rpc, &1, 2))

    %{implemented: implemented, not_implemented: atomized -- implemented}
  end

  def puts_implemented() do
    %{implemented: implemented, not_implemented: not_implemented} = calc_implemented(get_commands())

    num_implemented = length(implemented)
    total = num_implemented + length(not_implemented)
    percentage = Float.round(num_implemented / total * 100, 2)

    IO.puts("Number of commands implemented: #{num_implemented} / #{total} (#{percentage}%)")
    IO.puts("Implemented: #{Enum.join(implemented, ", ")}")
    IO.puts("Not implemented: #{Enum.join(not_implemented, ", ")}")
  end

  def update_badge() do
    %{implemented: implemented, not_implemented: not_implemented} = calc_implemented(get_commands())

    num_implemented = length(implemented)
    total = num_implemented + length(not_implemented)
    percentage = Float.round(num_implemented / total * 100, 2)

    File.write!(
      "README.md",
      File.read!("README.md")
      |> String.replace(
        ~r/(?<=\s)!\[IPFS RPC API Coverage\]\(https:\/\/img\.shields\.io\/badge\/IPFS%20RPC%20API%20Coverage-.*\)/,
        "![IPFS RPC API Coverage](https://img.shields.io/badge/IPFS%20RPC%20API%20Coverage-#{percentage}%25-#{get_color(percentage)})"
      )
    )
  end

  def get_color(percentage) do
    cond do
      percentage < 20 -> "red"
      percentage < 40 -> "orange"
      percentage < 60 -> "yellow"
      percentage < 80 -> "green"
      percentage < 100 -> "brightgreen"
      true -> "brightgreen"
    end
  end
end

alias KuboEx.IpfsDocs
IpfsDocs.puts_implemented()
IpfsDocs.update_badge()
