defmodule Hap.Events do
  @moduledoc """
  The Events context.
  """

  import Ecto.Query, warn: false

  alias Hap.Events.Event
  alias Hap.Repo
  alias Phoenix.PubSub

  @doc """
  Creates an event.
  """
  @spec create_event(map()) :: {:ok, Event.t()} | {:error, Ecto.Changeset.t()}
  def create_event(params \\ %{}),
    do: params |> create_event_changeset() |> Repo.insert() |> maybe_broadcast_event_added()

  @doc """
  Returns a changeset for creating a new event.
  """
  @spec create_event_changeset(map()) :: Ecto.Changeset.t()
  def create_event_changeset(params \\ %{}),
    do: Event.insert_changeset(%Event{}, params)

  @doc """
  Returns a list of events, ordered most recent to least recent.
  """
  @spec list_events() :: [Event.t()]
  def list_events,
    do: from(e in Event, order_by: [desc: e.logged_at]) |> Repo.all()

  defp maybe_broadcast_event_added({:ok, event}) do
    PubSub.broadcast(Hap.PubSub, "events", {:event_added, event})
    {:ok, event}
  end

  defp maybe_broadcast_event_added({:error, changeset}), do: {:error, changeset}
end
