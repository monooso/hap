defmodule Hap.ProjectsTest do
  use Hap.DataCase
  import Hap.Factory
  alias Ecto.Changeset
  alias Hap.Projects
  alias HapSchemas.Projects.Project

  describe "create_project/1" do
    setup do
      [
        valid_attrs: %{
          name: "Project Awesome",
          organization_id: insert(:organization) |> Map.get(:id)
        }
      ]
    end

    test "it returns an {:ok, %Project{}} tuple on success", %{valid_attrs: attrs} do
      assert {:ok, %Project{}} = Projects.create_project(attrs)
    end

    test "it returns an {:error, %Changeset{}} tuple on failure" do
      assert {:error, %Changeset{}} = Projects.create_project(%{})
    end
  end

  describe "create_project_changeset/1" do
    test "it returns a Project changeset" do
      assert %Changeset{data: %Project{}} = Projects.create_project_changeset(%{})
    end
  end
end
