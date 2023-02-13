defmodule Hap.Projects.Events do
  @moduledoc false

  alias Ecto.Changeset

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
