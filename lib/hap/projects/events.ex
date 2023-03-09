defmodule Hap.Projects.Events do
  @moduledoc false

  import Ecto.Query, warn: false
  alias Ecto.Changeset
  alias Ecto.Query
  alias Hap.Projects.EventQuery
  alias HapSchemas.Projects.Event

  @doc """
  Returns an Ecto.Query for retrieving the events belonging to the given project. Applies the
  conditions defined in the given event query filters.
  """
  @spec list_events_by_project_query(Integer.t(), EventQuery.t()) :: Query.t()
  def list_events_by_project_query(project_id, filters) do
    from(Event)
    |> filter_by_project(project_id)
    |> filter_by_message(filters)
    |> filter_by_name(filters)
    |> filter_by_tags(filters)
    |> apply_sorting(filters)
  end

  defp apply_sorting(query, %{sort_by: sort_by, sort_order: sort_order})
       when is_atom(sort_by) and is_atom(sort_order),
       do: from(e in query, order_by: [{^sort_order, ^sort_by}])

  defp apply_sorting(query, _), do: query

  defp filter_by_message(query, %{message: ""}), do: query

  defp filter_by_message(query, %{message: message}),
    do: from(e in query, where: ilike(e.message, ^"%#{message}%"))

  defp filter_by_name(query, %{name: ""}), do: query

  defp filter_by_name(query, %{name: name}),
    do: from(e in query, where: ilike(e.name, ^"%#{name}%"))

  defp filter_by_project(query, project_id),
    do: from(e in query, where: e.project_id == ^project_id)

  defp filter_by_tags(query, %{tags: []}), do: query

  defp filter_by_tags(query, %{tags: [""]}), do: query

  defp filter_by_tags(query, %{tags: tags}) do
    tags
    |> Enum.map(&normalize_string/1)
    |> Enum.reduce(query, fn tag, query ->
      from(e in query, where: ^tag in e.tags)
    end)
  end

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
