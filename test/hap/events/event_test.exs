defmodule Hap.Events.EventTest do
  use Hap.DataCase, async: true

  alias Hap.Events.Event

  describe "insert_changeset/2" do
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

    test "it returns a valid changeset when given valid params", %{params: params} do
      assert params |> insert_changeset() |> valid_changeset?()
    end

    test "it returns an invalid changeset when given invalid params" do
      refute %{} |> insert_changeset() |> valid_changeset?()
    end

    test "it validates the category parameter", %{params: params} do
      # Missing
      changeset = params |> Map.delete("category") |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{category: ["Please specify the category"]} = errors_on(changeset)

      # Empty string
      changeset = %{params | "category" => ""} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{category: ["Please specify the category"]} = errors_on(changeset)

      # Not a string
      changeset = %{params | "category" => 123} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{category: ["The category must be a string"]} = errors_on(changeset)

      # Too long
      changeset = %{params | "category" => String.duplicate("x", 256)} |> insert_changeset()
      refute valid_changeset?(changeset)

      assert %{category: ["The category cannot be longer than 255 characters"]} =
               errors_on(changeset)
    end

    test "it validates the name parameter", %{params: params} do
      # Missing
      changeset = params |> Map.delete("name") |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["Please specify the name"]} = errors_on(changeset)

      # Empty string
      changeset = %{params | "name" => ""} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["Please specify the name"]} = errors_on(changeset)

      # Not a string
      changeset = %{params | "name" => 123} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["The name must be a string"]} = errors_on(changeset)

      # Too long
      changeset = %{params | "name" => String.duplicate("x", 256)} |> insert_changeset()
      refute valid_changeset?(changeset)

      assert %{name: ["The name cannot be longer than 255 characters"]} =
               errors_on(changeset)
    end

    test "it validates the organization_id parameter", %{params: params} do
      # Missing
      changeset = params |> Map.delete("organization_id") |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{organization_id: ["Please specify the organization"]} = errors_on(changeset)

      # Does not exist
      {:error, changeset} =
        %{params | "organization_id" => 90_210}
        |> insert_changeset()
        |> perform_insert()

      assert %{organization_id: ["The specified organization does not exist"]} =
               errors_on(changeset)
    end

    test "it validates the payload parameter", %{params: params} do
      # Missing is okay
      changeset = params |> Map.delete("payload") |> insert_changeset()
      assert valid_changeset?(changeset)

      # Not a map
      changeset = %{params | "payload" => "denied"} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{payload: ["The payload must be a map"]} = errors_on(changeset)
    end
  end

  defp insert_changeset(params), do: Event.insert_changeset(%Event{}, params)

  defp perform_insert(changeset), do: Hap.Repo.insert(changeset)
end
