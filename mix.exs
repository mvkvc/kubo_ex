defmodule KuboEx.MixProject do
  use Mix.Project

  @description "Elixir library for interacting with a Kubo IPFS node."
  @source_url "https://github.com/mvkvc/kubo_ex"
  @version "0.1.0"

  def project do
    [
      app: :kubo_ex,
      description: @description,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      aliases: aliases(),
      dialyzer: [
        plt_local_path: "dialyzer",
        plt_core_path: "dialyzer"
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      extras: [
        {:"README.md", [title: "Overview"]},
        "LICENSE.md"
      ],
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}"
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 2.0"},
      {:jason, "~> 1.2"},
      {:floki, "~> 0.34.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp aliases do
    [
      docs: ["docs --formatter html"],
      badge: ["run priv/ipfs_docs.exs"]
    ]
  end
end
