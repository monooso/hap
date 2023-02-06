defmodule Hap.Projects do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias Hap.Repo
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Projects.Project

  @doc """
  Creates a project with the given attributes.
  """
  @spec create_project(map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
  def create_project(attrs) do
    attrs
    |> Map.put("api_key", Ecto.UUID.generate())
    |> create_project_changeset()
    |> Repo.insert()
  end

  @doc """
  Returns a changeset for creating a project.
  """
  @spec create_project_changeset(map()) :: Changeset.t()
  def create_project_changeset(attrs),
    do: Project.insert_changeset(%Project{}, attrs)

  @doc """
  Returns a list of projects belonging to the given organization.
  """
  @spec list_projects_by_organization(Ecto.UUID.t() | Organization.t()) :: list(Project.t())
  def list_projects_by_organization(%Organization{id: id}),
    do: list_projects_by_organization(id)

  def list_projects_by_organization(organization_id) do
    from(p in Project, where: p.organization_id == ^organization_id) |> Repo.all()
  end
end
