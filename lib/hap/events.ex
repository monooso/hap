defmodule Hap.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false

  alias Hap.Events.Event
  alias Hap.Repo

  @doc """
  Creates an event.
  """
  @spec create_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(params \\ %{}),
    do: params |> create_event_changeset() |> Repo.insert()

  @doc """
  Returns a changeset for creating a new event.
  """
  @spec create_event_changeset(map()) :: Ecto.Changeset.t()
  def create_event_changeset(params \\ %{}),
    do: Event.insert_changeset(%Event{}, params)
end
