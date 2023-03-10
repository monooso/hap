defmodule HapSchemas.Accounts.Organization do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias HapSchemas.Accounts.Member
  alias HapSchemas.Accounts.User

  @type t() :: %__MODULE__{}

  schema "organizations" do
    field(:name, :string)

    has_many(:members, Member)
    many_to_many(:users, User, join_through: Member)

    timestamps()
  end

  @doc """
  Returns a changeset for use when creating an organization.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> validate_name()
  end

  defp validate_name(changeset),
    do: validate_length(changeset, :name, min: 1, max: 255)
end
