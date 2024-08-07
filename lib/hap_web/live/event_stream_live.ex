defmodule HapWeb.EventStreamLive do
  alias Phoenix.PubSub
  alias Hap.Events
  use HapWeb, :live_view

  def mount(_params, _session, socket) do
    subscribe_to_messages()
    {:ok, socket |> stream_events()}
  end

  def handle_info({:event_added, new_event}, socket) do
    {:noreply, stream_insert(socket, :events, new_event)}
  end

  def render(assigns) do
    ~H"""
    <div id="events" phx-update="stream">
      <div :for={{id, event} <- @streams.events} data-event id={id}>
        <span data-event-category={event.category}><%= event.category %></span>
        <span data-event-name={event.name}><%= event.name %></span>
      </div>
    </div>
    """
  end

  defp stream_events(socket),
    do: stream(socket, :events, Events.list_events())

  defp subscribe_to_messages,
    do: PubSub.subscribe(Hap.PubSub, "events")
end
