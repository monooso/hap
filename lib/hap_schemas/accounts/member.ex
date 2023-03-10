defmodule HapSchemas.Accounts.Member do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset
  alias Ecto.Changeset
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Accounts.User

  @type t() :: %__MODULE__{}

  schema "members" do
    belongs_to(:organization, Organization)
    belongs_to(:user, User)

    timestamps()
  end

  @doc """
  Returns a changeset for use when creating a member.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, attrs) do
    struct_or_changeset
    |> cast(attrs, [:organization_id, :user_id])
    |> validate_required([:organization_id, :user_id])
    |> validate_organization()
    |> validate_user()
  end

  defp validate_organization(changeset),
    do: assoc_constraint(changeset, :organization)

  defp validate_user(changeset),
    do: assoc_constraint(changeset, :user)
end
