defmodule Hap.Projects do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias Hap.Projects
  alias Hap.Repo
  alias HapSchemas.Accounts.Organization
  alias HapSchemas.Projects.Event
  alias HapSchemas.Projects.Project
  alias HapSchemas.Ui.EventQuery

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
  Returns a changeset for filtering events.
  """
  @spec event_query_changeset(EventQuery.t() | Changeset.t(), map()) :: Changeset.t()
  def event_query_changeset(struct_or_changeset, attrs),
    do: EventQuery.changeset(struct_or_changeset, attrs)

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
  Returns a deduplicated list of event names belonging to the given project.
  """
  @spec list_distinct_event_names_by_project(Integer.t() | Project.t()) :: list(String.t())
  def list_distinct_event_names_by_project(%Project{id: id}),
    do: list_distinct_event_names_by_project(id)

  def list_distinct_event_names_by_project(project_id) do
    from(e in Event,
      where: e.project_id == ^project_id,
      distinct: true,
      select: e.name,
      order_by: [e.name]
    )
    |> Repo.all()
  end

  @doc """
  Returns a list of events belonging to the given project. Limits results to those matching the
  given filters.
  """
  @spec list_events_by_project(Integer.t() | Project.t(), EventQuery.t()) :: list(Event.t())
  def list_events_by_project(project, filters \\ %EventQuery{})

  def list_events_by_project(project, filters),
    do: Projects.Events.list_events_by_project_query(project, filters) |> Repo.all()

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
