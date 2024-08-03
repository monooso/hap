defmodule Hap.EventsTest do
  use Hap.DataCase, async: true

  alias Hap.Events
  alias Hap.Events.Event

  describe "create_event/1" do
    setup do
      [
        params: %{
          "category" => "testing_hap",
          "name" => "testing_create_event",
          "organization_id" => insert(:organization).id,
          "payload" => %{"valid" => true}
        }
      ]
    end

    test "it returns an {:ok, event} tuple when given valid params", %{params: params} do
      assert {:ok, %Event{}} = Events.create_event(params)
    end

    test "it creates an event with the given params", %{params: params} do
      {:ok, event} = Events.create_event(params)

      assert event.id
      assert event.category == params["category"]
      assert event.name == params["name"]
      assert event.payload == params["payload"]
    end

    test "it returns an {:error, changeset} tuple when given invalid params" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(%{})
    end
  end

  describe "create_event_changeset/1" do
    test "it returns an Ecto.Changeset struct" do
      assert %Ecto.Changeset{data: %Event{}} = Events.create_event_changeset(%{})
    end
  end
end
