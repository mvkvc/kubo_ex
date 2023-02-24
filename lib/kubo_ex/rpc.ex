defmodule KuboEx.Rpc do
  alias Ecto.Changeset
  alias KuboEx.RpcError

  def build_url(endpoint, command) do
    Path.join([endpoint, "api/v0", Enum.join(command, "/")])
  end

  def post(url, options) do
    with {:error, %HTTPoison.Error{reason: reason}} <- HTTPoison.post(url, "", [], options) do
      {:error, RpcError.http(reason)}
    end
  end

  def check_status(response) do
    with %HTTPoison.Response{status_code: 200} <- response do
      {:ok, response.body}
    else
      %HTTPoison.Response{status_code: code} -> {:error, RpcError.rpc(code)}
    end
  end

  def decode(response) do
    with {:error, _} <- Jason.decode(response) do
      {:error, RpcError.json("could not decode: #{inspect(response)}")}
    end
  end

  def request(config, command, opts \\ []) do
    url = build_url(config.endpoint, command)
    options = [params: opts]

    with {:ok, response} <- post(url, options),
         {:ok, body} <- check_status(response),
         {:ok, decoded} <- decode(body) do
      decoded
    end
  end

  def split_fname(fname) do
    fname
    |> elem(0)
    |> to_string()
    |> String.split("_")
  end

  def call(config, command, opts \\ [], types \\ %{}, changesets \\ []) do
    opts = Enum.into(opts, %{})

    changeset =
      {opts, types}
      |> Changeset.cast(opts, Map.keys(types))

    changeset = Enum.reduce(changesets, changeset, fn f, acc ->
      f.(acc)
    end)

    with {:ok, opts} <- Changeset.apply_action(changeset, :update),
         {:ok, result} <- request(config, command, opts) do
      result
    end
  end

  def id(config, opts \\ ['peerid-base': "b58mh"]) do
    types = %{
      arg: :string,
      format: :string,
      'peerid-base': :string
    }

    changesets = [
      &Changeset.validate_inclusion(&1, :'peerid-base', ["b58mh", "base36", "k", "base32", "b..."])
    ]

    call(config, split_fname(__ENV__.function), opts, types, changesets)
  end

  def files_ls(config, opts \\ [arg: "/"]) do
    types = %{
      arg: :string,
      long: :boolean,
      U: :boolean
    }

    call(config, split_fname(__ENV__.function), opts, types)
  end
end
