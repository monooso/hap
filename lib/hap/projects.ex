defmodule Hap.Projects do
  @moduledoc false

  alias Ecto.Changeset
  alias Hap.Repo
  alias HapSchemas.Projects.Project

  @doc """
  Creates a project with the given attributes.
  """
  @spec create_project(map()) :: {:ok, Project.t()} | {:error, Changeset.t()}
  def create_project(attrs) do
    attrs
    |> Map.put(:api_key, Ecto.UUID.generate())
    |> create_project_changeset()
    |> Repo.insert()
  end

  @doc """
  Returns a changeset for creating a project.
  """
  @spec create_project_changeset(map()) :: Changeset.t()
  def create_project_changeset(attrs),
    do: Project.insert_changeset(%Project{}, attrs)
end
