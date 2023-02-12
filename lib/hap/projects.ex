defmodule Hap.Projects do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias Hap.Repo
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Projects.Event
  alias HapSchemas.Projects.Project

  @doc """
  Creates an event for the given project with the given attributes.
  """
  @spec create_event(Project.t(), map()) :: {:ok, Event.t()} | {:error, Changeset.t()}
  def create_event(project, attrs) do
    changeset = project |> Ecto.build_assoc(:events) |> Event.insert_changeset(attrs)

    changeset =
      case changeset.valid? do
        true -> changeset |> normalize_tags_changes()
        false -> changeset
      end

    Repo.insert(changeset)
  end

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
  Returns the project associated with the given API key.
  """
  @spec get_project_by_api_key(Ecto.UUID.t()) :: Project.t()
  def get_project_by_api_key(api_key),
    do: Repo.get_by(Project, api_key: api_key)

  @doc """
  Returns a list of projects belonging to the given organization.
  """
  @spec list_projects_by_organization(Ecto.UUID.t() | Organization.t()) :: list(Project.t())
  def list_projects_by_organization(%Organization{id: id}),
    do: list_projects_by_organization(id)

  def list_projects_by_organization(organization_id) do
    from(p in Project, where: p.organization_id == ^organization_id) |> Repo.all()
  end

  @spec normalize_tags_changes(Changeset.t()) :: Changeset.t()
  defp normalize_tags_changes(changeset) do
    tags =
      Changeset.get_change(changeset, :tags, [])
      |> Enum.map(&(&1 |> String.trim() |> String.downcase()))

    Changeset.put_change(changeset, :tags, tags)
  end
end
