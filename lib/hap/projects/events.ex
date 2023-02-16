defmodule Hap.Projects.Events do
  @moduledoc false

  import Ecto.Query, only: [from: 2]
  alias Ecto.Changeset
  alias Ecto.Query
  alias HapSchemas.Projects.Event
  alias HapSchemas.Projects.Project
  alias HapSchemas.Ui.EventQuery

  @doc """
  Returns an Ecto.Query for retrieving the events belonging to the given project. Applies the
  conditions defined in the given EventQuery.
  """
  @spec list_events_by_project_query(Integer.t() | Project.t(), EventQuery.t()) :: Query.t()
  def list_events_by_project_query(%Project{id: id}, filters),
    do: list_events_by_project_query(id, filters)

  def list_events_by_project_query(project_id, filters),
    do: from(e in Event, where: e.project_id == ^project_id) |> apply_event_query_filters(filters)

  @doc """
  Normalizes the given changeset, if it contains valid changes.

  If the changeset is invalid, it is returned as-is.
  """
  @spec normalize_event_changeset(Changeset.t()) :: Changeset.t()
  def normalize_event_changeset(%Changeset{valid?: true} = changeset) do
    changeset
    |> normalize_metadata_keys()
    |> normalize_name()
    |> normalize_tags()
    |> deduplicate_tags()
  end

  def normalize_event_changeset(changeset), do: changeset

  @spec apply_event_query_filters(Query.t(), EventQuery.t()) :: Query.t()
  defp apply_event_query_filters(query, filters) do
    filters
    |> Map.from_struct()
    |> Enum.reduce(query, fn {key, value}, query ->
      apply_event_query_filter(query, key, value)
    end)
  end

  @spec apply_event_query_filter(Query.t(), atom, any) :: Query.t()
  defp apply_event_query_filter(query, :message, message) when not is_nil(message),
    do: from(e in query, where: ilike(e.message, ^"%#{message}%"))

  defp apply_event_query_filter(query, :name, name) when not is_nil(name),
    do: from(e in query, where: ilike(e.name, ^"%#{name}%"))

  defp apply_event_query_filter(query, _key, _value), do: query

  @spec deduplicate_tags(Changeset.t()) :: Changeset.t()
  defp deduplicate_tags(changeset) do
    tags = Changeset.get_change(changeset, :tags, []) |> Enum.uniq()
    Changeset.put_change(changeset, :tags, tags)
  end

  @spec normalize_metadata_keys(Changeset.t()) :: Changeset.t()
  defp normalize_metadata_keys(changeset) do
    metadata =
      Changeset.get_change(changeset, :metadata, %{})
      |> Map.new(fn {key, value} ->
        {normalize_string(key), value}
      end)

    Changeset.put_change(changeset, :metadata, metadata)
  end

  @spec normalize_name(Changeset.t()) :: Changeset.t()
  defp normalize_name(changeset) do
    name = Changeset.get_change(changeset, :name, "") |> normalize_string()
    Changeset.put_change(changeset, :name, name)
  end

  @spec normalize_string(String.t()) :: String.t()
  defp normalize_string(string) do
    string
    |> String.trim()
    |> String.downcase()
    |> String.replace(~r/[\s]+/, " ")
    |> String.replace(~r/["'`]/, "")
  end

  @spec normalize_tags(Changeset.t()) :: Changeset.t()
  defp normalize_tags(changeset) do
    tags = Changeset.get_change(changeset, :tags, []) |> Enum.map(&normalize_string/1)
    Changeset.put_change(changeset, :tags, tags)
  end
end
