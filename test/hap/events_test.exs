defmodule Hap.EventsTest do
  use Hap.DataCase, async: true

  alias Hap.Events
  alias Hap.Events.Event
  alias Phoenix.PubSub

  describe "create_event/1" do
    setup do
      [
        params: %{
          "category" => "testing_hap",
          "name" => "testing_create_event",
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

    test "it broadcasts a message when a new event is created", %{params: params} do
      subscribe_to_messages()
      {:ok, event} = Events.create_event(params)
      assert_message_received({:event_added, event})
    end

    test "it returns an {:error, changeset} tuple when given invalid params" do
      assert {:error, %Ecto.Changeset{}} = Events.create_event(%{})
    end

    test "it does not broadcast a message if a new event is not created" do
      subscribe_to_messages()
      {:error, _changeset} = Events.create_event(%{})
      assert_no_messages_received()
    end
  end

  describe "create_event_changeset/1" do
    test "it returns an Ecto.Changeset struct" do
      assert %Ecto.Changeset{data: %Event{}} = Events.create_event_changeset(%{})
    end
  end

  describe "list_events/0" do
    test "it returns a list of events, ordered most recent to least recent" do
      now = DateTime.utc_now()

      insert(:event, category: "hap", name: "zulu", logged_at: DateTime.add(now, -1, :second))
      insert(:event, category: "hap", name: "alpha", logged_at: now)

      assert [%Event{name: "alpha"}, %Event{name: "zulu"}] = Events.list_events()
    end
  end

  defp assert_message_received(message),
    do: assert({:messages, [^message]} = Process.info(self(), :messages))

  defp assert_no_messages_received,
    do: assert({:messages, []} = Process.info(self(), :messages))

  defp subscribe_to_messages,
    do: PubSub.subscribe(Hap.PubSub, "events")
end
