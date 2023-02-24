defmodule KuboEx do
  @moduledoc """
  Documentation for `KuboEx`.
  """

  alias Ecto.Changeset

  @type config :: %{endpoint: String.t()}

  @doc """
  Returns the default configuration for KuboEx.
  """
  @spec default_config :: config
  def default_config do
    %{endpoint: "http://localhost:5001"}
  end

  @doc """
  Returns a configuration for KuboEx.
  """
  @spec config!(Keyword.t()) :: config
  def config!(opts \\ []) do
    opts = Enum.into(opts, %{})
    config = default_config()

    types = %{
      endpoint: :string
    }

    changeset =
      {config, types}
      |> Changeset.cast(opts, Map.keys(types))
      |> Changeset.validate_required([:endpoint])

    case Changeset.apply_action(changeset, :update) do
      {:ok, config} -> config
      {:error, changeset} -> raise "Invalid config: #{inspect(changeset)}"
    end
  end
end
