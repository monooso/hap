defmodule HapSchemas.Projects.EventTest do
  use Hap.DataCase, asyc: true
  import Hap.Factory
  alias Ecto.Changeset
  alias HapSchemas.Projects.Event

  describe "insert_changeset/2" do
    setup do
      project = insert(:project)

      [
        valid_attrs: %{
          message: "We have a new order!",
          metadata: %{
            "customer_id" => 123,
            order_id: 456,
            order_total: 99.87,
            order_status: "received",
            free_shipping: true
          },
          name: "Order Received",
          project_id: project.id,
          tags: ["kpi", "sales"]
        }
      ]
    end

    test "it returns a valid changeset when given valid data", %{valid_attrs: attrs} do
      assert %Changeset{valid?: true} = Event.insert_changeset(%Event{}, attrs)
    end

    test "insert works when given valid data", %{valid_attrs: attrs} do
      {:ok, %Event{}} = %Event{} |> Event.insert_changeset(attrs) |> Repo.insert()
    end

    test "the name attribute is required", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :name)
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "the name cannot be longer than 255 characters", %{valid_attrs: attrs} do
      attrs = %{attrs | name: String.duplicate("a", 256)}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "the message attribute is optional", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :message)
      assert %Changeset{valid?: true} = Event.insert_changeset(%Event{}, attrs)
    end

    test "if given, the message cannot be longer than 255 characters", %{valid_attrs: attrs} do
      attrs = %{attrs | message: String.duplicate("a", 256)}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{message: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "the tags attribute is optional", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :tags)
      assert %Changeset{valid?: true} = Event.insert_changeset(%Event{}, attrs)
    end

    test "if given, the tags attribute must be a list", %{valid_attrs: attrs} do
      attrs = %{attrs | tags: "not a list"}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{tags: ["is invalid"]} = errors_on(changeset)
    end

    test "if given, the tags attribute must be a list of strings", %{valid_attrs: attrs} do
      attrs = %{attrs | tags: [123, false, %{}]}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{tags: ["is invalid"]} = errors_on(changeset)
    end

    test "the metadata attribute is optional", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :metadata)
      assert %Changeset{valid?: true} = Event.insert_changeset(%Event{}, attrs)
    end

    test "if given, the metadata attribute must be a map", %{valid_attrs: attrs} do
      attrs = %{attrs | metadata: "not a map"}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{metadata: ["is invalid"]} = errors_on(changeset)
    end

    test "if given, the metadata attribute keys must strings or atoms", %{valid_attrs: attrs} do
      attrs = %{attrs | metadata: %{123 => "numeric key", %{key: :invalid} => "map key"}}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{metadata: ["keys must be strings"]} = errors_on(changeset)
    end

    test "if given, the metadata attribute values must be primitive types", %{valid_attrs: attrs} do
      attrs = %{attrs | metadata: %{"name" => %{"first" => "John", "last" => "Doe"}}}
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{metadata: ["values must be strings, numbers, or booleans"]} = errors_on(changeset)
    end

    test "the project_id attribute is required", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :project_id)
      changeset = Event.insert_changeset(%Event{}, attrs)

      assert %{project_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "the project_id must refer to a known project", %{valid_attrs: attrs} do
      attrs = %{attrs | project_id: 123}
      {:error, changeset} = Event.insert_changeset(%Event{}, attrs) |> Repo.insert()

      assert %{project: ["does not exist"]} = errors_on(changeset)
    end
  end
end
