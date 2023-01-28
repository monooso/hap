defmodule HapSchemas.Accounts.Organization do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias HapSchemas.Accounts.User

  @type t() :: %__MODULE__{}

  schema "organizations" do
    field :name, :string

    has_many :users, User

    timestamps()
  end

  @doc """
  Returns a changeset for use when creating an organisation.
  """
  @spec insert_changeset(__MODULE__.t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, attrs),
    do: base_changeset(struct_or_changeset, attrs)

  @doc """
  Returns a changeset for use when updating an organisation.
  """
  @spec update_changeset(__MODULE__.t() | Changeset.t(), map()) :: Changeset.t()
  def update_changeset(struct_or_changeset, attrs),
    do: base_changeset(struct_or_changeset, attrs)

  @spec base_changeset(__MODULE__.t() | Changeset.t(), map()) :: Changeset.t()
  defp base_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_length(:name, max: 255)
  end
end
