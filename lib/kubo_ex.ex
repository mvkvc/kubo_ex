defmodule KuboEx do
  @moduledoc """
  KuboEx is a client for the Kubo API.
  """
  alias Ecto.Changeset

  @type config :: %{endpoint: String.t()}

  @spec default_config() :: config
  def default_config() do
    %{endpoint: "http://localhost:5001"}
  end

  @spec config!(Keyword.t()) :: config
  def config!(opts \\ []) do
    config = default_config()
    opts = Enum.into(opts, %{})

    types = %{
      endpoint: :string
    }

    changeset =
      {config, types}
      |> Changeset.cast(opts, Map.keys(types))
      |> Changeset.validate_required([:endpoint])

    # NOTE: Create a struct to apply the changeset, check elixir school etc

    # Describes the action for observability reasons, errors, etc look into more
    case Changeset.apply_action(changeset, :update) do
      {:ok, config} -> config
      {:error, changeset} -> raise "Invalid config: #{inspect(changeset)}"
    end
  end
end
