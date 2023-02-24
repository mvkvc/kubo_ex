alias Ecto.Changeset

opts = [arg: "foo"]

changesets = [
  &Changeset.validate_exclusion(&1, :arg, ["foo", "bar"]),
  &Changeset.validate_length(&1, :arg, min: 2, max: 10),
  &Changeset.validate_format(&1, :arg, ~r/^[a-z]+$/)
]

types = %{
  arg: :string,
  long: :boolean,
  U: :boolean
}

changeset =
  {opts, types}
  |> Changeset.cast(opts, Map.keys(types))
  |> Enum.reduce(changesets, & &2.(&1))
