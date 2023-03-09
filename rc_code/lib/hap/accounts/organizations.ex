defmodule Hap.Accounts.Organizations do
  @moduledoc false

  alias Ecto.Changeset
  alias HapSchemas.Accounts.Organization

  @doc """
  Returns a changeset for creating an organisation.
  """
  @spec create_organization_changeset(map()) :: Changeset.t()
  def create_organization_changeset(attrs),
    do: Organization.insert_changeset(%Organization{}, attrs)
end
