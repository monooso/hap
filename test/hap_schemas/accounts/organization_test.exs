defmodule HapSchemas.Accounts.OrganizationTest do
  use Hap.DataCase
  alias Ecto.Changeset
  alias HapSchemas.Accounts.Organization

  describe "insert_changeset/2" do
    setup do
      [attrs: %{name: "Test Organization"}]
    end

    test "it returns a valid changeset when given valid data", %{attrs: attrs} do
      assert %Changeset{valid?: true} = Organization.insert_changeset(%Organization{}, attrs)
    end

    test "it validates that the name is given", %{attrs: attrs} do
      attrs = Map.delete(attrs, :name)
      changeset = Organization.insert_changeset(%Organization{}, attrs)

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "it validates the maximum length of the name", %{attrs: attrs} do
      attrs = %{attrs | name: String.duplicate("a", 256)}
      changeset = Organization.insert_changeset(%Organization{}, attrs)

      assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end
  end

  describe "update_changeset/2" do
    setup do
      [attrs: %{name: "Test Organization"}]
    end

    test "it returns a valid changeset when given valid data", %{attrs: attrs} do
      assert %Changeset{valid?: true} = Organization.update_changeset(%Organization{}, attrs)
    end

    test "it validates that the name is given", %{attrs: attrs} do
      attrs = Map.delete(attrs, :name)
      changeset = Organization.update_changeset(%Organization{}, attrs)

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "it validates the maximum length of the name", %{attrs: attrs} do
      attrs = %{attrs | name: String.duplicate("a", 256)}
      changeset = Organization.update_changeset(%Organization{}, attrs)

      assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end
  end
end
