defmodule Hap.Organizations.OrganizationTest do
  use Hap.DataCase, async: true

  alias Hap.Organizations.Organization

  describe "insert_changeset/2" do
    setup do
      [params: %{"name" => "Big Corp"}]
    end

    test "it returns a valid changeset when given valid params", %{params: params} do
      assert params |> insert_changeset() |> valid_changeset?()
    end

    test "it returns an invalid changeset when given invalid params" do
      refute %{} |> insert_changeset() |> valid_changeset?()
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
  end

  defp insert_changeset(params), do: Organization.insert_changeset(%Organization{}, params)
end
