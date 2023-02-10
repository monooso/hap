defmodule HapSchemas.Projects.Event do
  @moduledoc false

  import Ecto.Changeset
  use Ecto.Schema
  alias Ecto.Changeset
  alias HapSchemas.Projects.Project

  @type t() :: %__MODULE__{}

  schema "events" do
    field :name, :string
    field :message, :string
    field :tags, {:array, :string}
    field :metadata, :map

    belongs_to :project, Project

    timestamps()
  end

  @doc """
  Returns a changeset for creating an event.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:name, :message, :tags, :metadata, :project_id])
    |> validate_required([:name, :project_id])
    |> validate_message()
    |> validate_metadata()
    |> validate_name()
    |> validate_project()
  end

  @spec atom_or_string?(any()) :: boolean()
  defp atom_or_string?(key) when is_atom(key), do: true
  defp atom_or_string?(key) when is_binary(key), do: true
  defp atom_or_string?(_key), do: false

  @spec primitive?(any()) :: boolean()
  defp primitive?(value) when is_binary(value), do: true
  defp primitive?(value) when is_boolean(value), do: true
  defp primitive?(value) when is_number(value), do: true
  defp primitive?(_value), do: false

  @spec validate_message(Changeset.t()) :: Changeset.t()
  defp validate_message(changeset),
    do: validate_length(changeset, :message, min: 1, max: 255)

  @spec validate_metadata(Changeset.t()) :: Changeset.t()
  defp validate_metadata(changeset) do
    metadata = get_change(changeset, :metadata, %{})
    result = {valid_metadata_keys?(metadata), valid_metadata_values?(metadata)}

    case result do
      {true, true} ->
        changeset

      {false, _} ->
        add_error(changeset, :metadata, "keys must be strings")

      {_, false} ->
        add_error(changeset, :metadata, "values must be strings, numbers, or booleans")
    end
  end

  @spec valid_metadata_keys?(map()) :: boolean()
  defp valid_metadata_keys?(metadata),
    do: metadata |> Map.keys() |> Enum.all?(&atom_or_string?/1)

  @spec valid_metadata_values?(map()) :: boolean()
  defp valid_metadata_values?(metadata),
    do: metadata |> Map.values() |> Enum.all?(&primitive?/1)

  @spec validate_name(Changeset.t()) :: Changeset.t()
  defp validate_name(changeset),
    do: validate_length(changeset, :name, min: 1, max: 255)

  @spec validate_project(Changeset.t()) :: Changeset.t()
  defp validate_project(changeset),
    do: assoc_constraint(changeset, :project)
end
