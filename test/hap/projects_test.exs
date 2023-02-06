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
          "name" => "Project Awesome",
          "organization_id" => insert(:organization) |> Map.get(:id)
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

  describe "list_projects_by_organization/1" do
    test "it returns a list of project structs" do
      organization = insert(:organization)
      insert_pair(:project, organization: organization)

      assert [%Project{}, %Project{}] = Projects.list_projects_by_organization(organization.id)
    end

    test "it only includes projects for the specified organization" do
      %{id: project_id, organization_id: organization_id} = insert(:project)
      insert(:project)

      assert [%Project{id: ^project_id}] = Projects.list_projects_by_organization(organization_id)
    end
  end
end
