defmodule HapWeb.Api.EventJSON do
  alias Hap.Events.Event

  @doc """
  Renders an event as JSON.
  """
  def show(%{event: event}),
    do: %{data: data(event)}

  defp data(%Event{} = event) do
    %{
      id: event.id,
      category: event.category,
      name: event.name,
      payload: event.payload,
      logged_at: event.logged_at
    }
  end
end
