defmodule Hap.EventsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Hap.Events` context.
  """

  @doc """
  Generate a event.
  """
  def event_fixture(attrs \\ %{}) do
    {:ok, event} =
      attrs
      |> Enum.into(%{
        category: "some category",
        name: "some name",
        payload: %{}
      })
      |> Hap.Events.create_event()

    event
  end
end
