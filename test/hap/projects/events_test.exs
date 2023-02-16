defmodule Hap.Projects.EventsTest do
  import Hap.Factory
  use Hap.DataCase, async: true
  alias Ecto.Changeset
  alias Ecto.Query
  alias Hap.Projects.Events
  alias HapSchemas.Projects.Event
  alias HapSchemas.Ui.EventQuery

  describe "list_events_by_project_query/2" do
    setup do
      [project: insert(:project)]
    end

    test "it returns an Ecto.Query struct", %{project: project} do
      assert %Query{} = Events.list_events_by_project_query(project, %EventQuery{})
    end

    test "it limits results to events belonging to the given project", %{project: project} do
      insert(:event)

      %{id: event_id} = insert(:event, project: project)

      assert [%Event{id: ^event_id}] =
               Events.list_events_by_project_query(project, %EventQuery{}) |> Repo.all()
    end

    test "it limits results to events with a name containing the given string", %{
      project: project
    } do
      insert(:event, project: project, name: "Billy Ray")

      %{id: event_id} = insert(:event, project: project, name: "Jim Bob")

      assert [%Event{id: ^event_id}] =
               Events.list_events_by_project_query(project, %EventQuery{name: "jim bo"})
               |> Repo.all()
    end

    test "it limits results to events with a message containing the given string", %{
      project: project
    } do
      insert(:event, project: project, message: "It was the best of times...")

      %{id: event_id} =
        insert(:event,
          project: project,
          message: "We were somewhere around Barstow, on the edge of the desert"
        )

      assert [%Event{id: ^event_id}] =
               Events.list_events_by_project_query(project, %EventQuery{message: "around bar"})
               |> Repo.all()
    end

    test "it limits results by multiple query conditions", %{project: project} do
      insert(:event, project: project, name: "Order placed", message: "Mad dollar bills, yo")
      insert(:event, project: project, name: "Donation received", message: "Mad dollar bills, yo")

      %{id: event_id} =
        insert(:event, project: project, name: "Order placed", message: "Break out the champers")

      assert [%Event{id: ^event_id}] =
               Events.list_events_by_project_query(project, %EventQuery{
                 message: "the champ",
                 name: "placed"
               })
               |> Repo.all()
    end
  end

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

    test "deduplicates the tags list after normalization", %{valid_attrs: attrs} do
      attrs = %{attrs | "tags" => ["KPI", "KPI", "kpi", "kpi"]}

      assert ["kpi"] =
               Event.insert_changeset(%Event{}, attrs)
               |> Events.normalize_event_changeset()
               |> Changeset.get_change(:tags)
    end
  end
end
