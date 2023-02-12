defmodule Hap.Projects.EventsTest do
  use ExUnit.Case, async: true
  alias Ecto.Changeset
  alias Hap.Projects.Events
  alias HapSchemas.Projects.Event

  describe "normalize_event_changeset/1" do
    setup do
      [
        valid_attrs: %{
          "name" => "Order Received",
          "tags" => ["kpi", "sales"],
          "metadata" => %{"customer_id" => 123},
          "project_id" => 123
        }
      ]
    end

    test "it does not attempt to normalize an invalid changeset", %{valid_attrs: attrs} do
      attrs = %{attrs | "metadata" => %{{"aw", "hell", "no"} => true, "tags" => "invalid"}}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert ^changeset = Events.normalize_event_changeset(changeset)
    end

    test "it normalizes the metadata keys", %{valid_attrs: attrs} do
      attrs = %{attrs | "metadata" => %{"  Customer-ID  " => 123, "'Order':  \"ID\"" => 456}}

      assert %{"customer-id" => 123, "order: id" => 456} =
               Event.insert_changeset(%Event{}, attrs)
               |> Events.normalize_event_changeset()
               |> Changeset.get_change(:metadata)
    end

    test "it normalizes the name", %{valid_attrs: attrs} do
      attrs = %{attrs | "name" => "  'Order~  \"Received?  "}

      assert "order~ received?" =
               Event.insert_changeset(%Event{}, attrs)
               |> Events.normalize_event_changeset()
               |> Changeset.get_change(:name)
    end

    test "it normalizes the tags", %{valid_attrs: attrs} do
      attrs = %{attrs | "tags" => ["KPI", "customer order", "  \"what'`-the:    heck?  "]}

      assert ["kpi", "customer order", "what-the: heck?"] =
               Event.insert_changeset(%Event{}, attrs)
               |> Events.normalize_event_changeset()
               |> Changeset.get_change(:tags)
    end
  end
end
