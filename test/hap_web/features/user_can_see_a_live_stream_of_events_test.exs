defmodule HapWeb.Features.UserCanSeeALiveStreamOfEventsTest do
  alias Hap.Events
  use HapWeb.FeatureCase, async: true

  setup attrs do
    register_and_log_in_user(attrs)
  end

  test "a logged-in user can see a live stream of events", %{conn: conn} do
    event_details = %{category: "hap", name: "live_stream_test"}

    conn
    |> visit_events_dashboard()
    |> assert_event_stream_is_empty()
    |> create_an_event(event_details)
    |> assert_event_stream_contains_new_event(event_details)
  end

  defp assert_event_stream_contains_new_event(session, event_details) do
    assert_has(session, "[data-event]", count: 1)
    assert_has(session, "[data-event-category]", text: event_details.category)
    assert_has(session, "[data-event-name]", text: event_details.name)
  end

  defp assert_event_stream_is_empty(session) do
    refute_has(session, "[data-event]")
  end

  defp create_an_event(session, event_details) do
    Events.create_event(event_details)
    session
  end

  defp visit_events_dashboard(conn),
    do: visit(conn, "/dashboard")
end
