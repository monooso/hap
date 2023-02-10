defmodule HapSchemas.Projects.ProjectTest do
  use Hap.DataCase, async: true
  import Hap.Factory
  alias Ecto.Changeset
  alias Hap.Repo
  alias HapSchemas.Projects.Project

  describe "insert_changeset/2" do
    setup do
      organization = insert(:organization)

      [
        valid_attrs: %{
          api_key: Ecto.UUID.generate(),
          name: "My Project",
          organization_id: organization.id
        }
      ]
    end

    test "it returns a valid changeset when given valid data", %{valid_attrs: attrs} do
      assert %Changeset{valid?: true} = Project.insert_changeset(%Project{}, attrs)
    end

    test "insert works when given valid data", %{valid_attrs: attrs} do
      {:ok, %Project{}} = %Project{} |> Project.insert_changeset(attrs) |> Repo.insert()
    end

    test "the api_key attribute is required", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :api_key)
      changeset = Project.insert_changeset(%Project{}, attrs)

      assert %{api_key: ["can't be blank"]} = errors_on(changeset)
    end

    test "the api_key cannot be longer than 255 characters", %{valid_attrs: attrs} do
      attrs = %{attrs | api_key: String.duplicate("a", 256)}

      changeset = Project.insert_changeset(%Project{}, attrs)

      assert %{api_key: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "the api_key must be unique", %{valid_attrs: attrs} do
      insert(:project, api_key: attrs.api_key)

      {:error, changeset} = %Project{} |> Project.insert_changeset(attrs) |> Repo.insert()

      assert %{api_key: ["has already been taken"]} = errors_on(changeset)
    end

    test "the name attribute is required", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :name)
      changeset = Project.insert_changeset(%Project{}, attrs)

      assert %{name: ["can't be blank"]} = errors_on(changeset)
    end

    test "the name cannot be longer than 255 characters", %{valid_attrs: attrs} do
      attrs = %{attrs | name: String.duplicate("a", 256)}

      changeset = Project.insert_changeset(%Project{}, attrs)

      assert %{name: ["should be at most 255 character(s)"]} = errors_on(changeset)
    end

    test "the organization_id attribute is required", %{valid_attrs: attrs} do
      attrs = Map.delete(attrs, :organization_id)
      changeset = Project.insert_changeset(%Project{}, attrs)

      assert %{organization_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "the organization_id must refer to a known organization", %{valid_attrs: attrs} do
      attrs = %{attrs | organization_id: 12345}

      {:error, changeset} = %Project{} |> Project.insert_changeset(attrs) |> Repo.insert()

      assert %{organization: ["does not exist"]} = errors_on(changeset)
    end
  end
end
