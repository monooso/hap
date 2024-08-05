defmodule HapWeb.Features.ApiClientCanLogAnEventTest do
  use HapWeb.ConnCase, async: true

  import Ecto.Query, only: [from: 2]

  alias Hap.Events.Event

  test "an api client can log an event", %{conn: conn} do
    payload = %{
      "category" => "hap",
      "name" => "happy_path",
      "payload" => %{"feature_test" => true}
    }

    conn
    |> authenticate_request()
    |> send_request_data_to_endpoint(payload)
    |> assert_api_response_code_is_created()
    |> assert_api_response_contains_event_details(payload)
    |> assert_event_was_logged(payload)
  end

  defp assert_api_response_code_is_created(conn) do
    assert conn.status == 201
    conn
  end

  defp assert_api_response_contains_event_details(conn, payload) do
    event = Jason.decode!(conn.resp_body)["data"]

    assert event["category"] == payload["category"]
    assert event["id"] |> is_integer() |> Kernel.>(0)
    assert event["name"] == payload["name"]
    assert event["payload"] == payload["payload"]
    assert {:ok, _logged_at, _} = event["logged_at"] |> DateTime.from_iso8601()

    conn
  end

  defp assert_event_was_logged(conn, %{
         "category" => category,
         "name" => name,
         "payload" => payload
       }) do
    assert from(e in Event, where: [category: ^category, name: ^name, payload: ^payload])
           |> Hap.Repo.one()

    conn
  end

  defp authenticate_request(conn), do: conn

  defp send_request_data_to_endpoint(conn, payload) do
    post(conn, ~p"/api/events", data: payload)
  end
end
