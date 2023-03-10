defmodule HapSchemas.Projects.Project do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Projects.Event

  @type t() :: %__MODULE__{}

  @derive {Phoenix.Param, key: :slug}
  schema "projects" do
    field :api_key, :string
    field :name, :string
    field :slug, :string

    belongs_to :organization, Organization
    has_many :events, Event

    timestamps()
  end

  @doc """
  Returns a changeset for creating a new project.
  """
  @spec insert_changeset(__MODULE__.t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:api_key, :name, :organization_id, :slug])
    |> validate_required([:api_key, :name, :organization_id, :slug])
    |> validate_api_key()
    |> validate_name()
    |> validate_organization()
    |> validate_slug()
  end

  @spec validate_api_key(Changeset.t()) :: Changeset.t()
  defp validate_api_key(changeset) do
    changeset
    |> validate_length(:api_key, min: 1, max: 255)
    |> unique_constraint(:api_key)
  end

  @spec validate_name(Changeset.t()) :: Changeset.t()
  defp validate_name(changeset),
    do: validate_length(changeset, :name, min: 1, max: 255)

  @spec validate_organization(Changeset.t()) :: Changeset.t()
  defp validate_organization(changeset),
    do: assoc_constraint(changeset, :organization)

  @spec validate_slug(Changeset.t()) :: Changeset.t()
  defp validate_slug(changeset) do
    changeset
    |> validate_length(:slug, min: 1, max: 255)
    |> unique_constraint(:slug)
  end
end
