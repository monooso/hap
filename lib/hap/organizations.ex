defmodule Hap.Organizations do
  @moduledoc """
  The Organizations context.
  """

  import Ecto.Query, warn: false
  alias Hap.Repo

  alias Hap.Organizations.Organization

  @doc """
  Returns a list of organizations.
  """
  def list_organizations,
    do: from(o in Organization, order_by: [asc: o.name]) |> Repo.all()

  @doc """
  Creates a organization.
  """
  @spec create_organization(map()) :: {:ok, Organization.t()} | {:error, Ecto.Changeset.t()}
  def create_organization(params \\ %{}),
    do: params |> create_organization_changeset() |> Repo.insert()

  @doc """
  Returns a changeset for creating a new organization.
  """
  @spec create_organization_changeset(map()) :: Ecto.Changeset.t()
  def create_organization_changeset(params \\ %{}),
    do: Organization.insert_changeset(%Organization{}, params)
end
