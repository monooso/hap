defmodule Hap.ProjectsTest do
  use Hap.DataCase, async: true
  import Hap.Factory
  alias Ecto.Changeset
  alias Hap.Projects
  alias HapSchemas.Projects.Event
  alias HapSchemas.Projects.Project

  describe "create_event/2" do
    setup do
      [
        project: insert(:project),
        valid_attrs: %{
          "name" => "Order Received",
          "message" => "We have a new order!",
          "tags" => ["kpi", "sales"],
          "metadata" => %{
            "customer_id" => 123,
            "order_id" => 456,
            "order_total" => 99.87,
            "order_status" => "received",
            "free_shipping" => true
          }
        }
      ]
    end

    test "it returns an {:ok, %Event{}} tuple on success", %{project: project, valid_attrs: attrs} do
      assert {:ok, %Event{}} = Projects.create_event(project, attrs)
    end

    test "it returns an {:error, %Changeset{}} tuple on failure", %{project: project} do
      assert {:error, %Changeset{}} = Projects.create_event(project, %{})
    end

    test "it normalizes the tags", %{project: project, valid_attrs: attrs} do
      attrs = %{attrs | "tags" => ["KPI", "customer order", "  what-the:heck?  "]}

      assert {:ok, %{tags: tags}} = Projects.create_event(project, attrs)
      assert ["kpi", "customer order", "what-the:heck?"] = tags
    end
  end

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

  describe "get_project_by_api_key/1" do
    test "it returns the project associated with the given API key" do
      %{id: project_id, api_key: api_key} = insert(:project)
      assert %Project{id: ^project_id} = Projects.get_project_by_api_key(api_key)
    end

    test "it returns nil if the project does not exist" do
      assert Ecto.UUID.generate() |> Projects.get_project_by_api_key() |> is_nil()
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
