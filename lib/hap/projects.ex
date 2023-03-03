defmodule Hap.Projects do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias Hap.Projects
  alias Hap.Projects.EventQuery
  alias Hap.Repo
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Projects.Event
  alias HapSchemas.Projects.Project

  @doc """
  Creates an event for the given project with the given attributes.
  """
  @spec create_event(Project.t(), map()) :: {:ok, Event.t()} | {:error, Changeset.t()}
  def create_event(project, attrs) do
    project
    |> Ecto.build_assoc(:events)
    |> Event.insert_changeset(attrs)
    |> Projects.Events.normalize_event_changeset()
    |> Repo.insert()
  end

  @doc """
  Creates a project with the given attributes.
  """
  @spec create_project(map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
  def create_project(attrs) do
    attrs
    |> Map.put("api_key", Ecto.UUID.generate())
    |> Map.put("slug", Hap.Helpers.Slugger.generate_random_slug())
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
  Returns the project identified by the given id.

  Raises an `Ecto.NoResultsError` if the project does not exist.
  """
  @spec get_project!(Integer.t()) :: Project.t()
  def get_project!(id),
    do: Repo.get!(Project, id)

  @doc """
  Returns the project associated with the given API key.
  """
  @spec get_project_by_api_key(Ecto.UUID.t()) :: Project.t()
  def get_project_by_api_key(api_key),
    do: Repo.get_by(Project, api_key: api_key)

  @doc """
  Returns the project identified by the given slug.

  Raises an `Ecto.NoResultsError` if the project does not exist.
  """
  @spec get_project_by_slug!(String.t()) :: Project.t()
  def get_project_by_slug!(slug),
    do: Repo.get_by!(Project, slug: slug)

  @doc """
  Returns a list of events belonging to the given project. Limits results to those matching the
  given filters.
  """
  @spec list_events_by_project(Integer.t() | Project.t(), EventQuery.t()) :: list(Event.t())
  def list_events_by_project(project_or_id, filters \\ %EventQuery{})

  def list_events_by_project(%Project{id: id}, filters),
    do: list_events_by_project(id, filters)

  def list_events_by_project(project_id, filters),
    do: Projects.Events.list_events_by_project_query(project_id, filters) |> Repo.all()

  @doc """
  Returns a list of projects belonging to the given organization.
  """
  @spec list_projects_by_organization(Integer.t() | Organization.t()) :: list(Project.t())
  def list_projects_by_organization(%Organization{id: id}),
    do: list_projects_by_organization(id)

  def list_projects_by_organization(organization_id) do
    from(p in Project, where: p.organization_id == ^organization_id) |> Repo.all()
  end
end
