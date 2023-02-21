defmodule KuboEx do
  @type config :: %{endpoint: String.t()}

  @spec default_config() :: config
  def default_config() do
    %{endpoint: "http://localhost:5001"}
  end

  @spec config!(Keyword.t()) :: config
  def config!(opts \\ []) do
    config = default_config()

    keys_config = Map.keys(config)
    keys_opts = Keyword.keys(opts)
    key_diff = keys_opts -- keys_config

    if key_diff != [] do
      raise ArgumentError, "Invalid option(s) in opts: #{inspect(key_diff)}"
    else
      config
      |> Map.merge(Enum.into(opts, %{}))
    end

    # TODO: Validate types in config conform to type definition
  end
end
