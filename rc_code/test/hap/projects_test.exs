defmodule Hap.ProjectsTest do
  use Hap.DataCase, async: true
  import Hap.Factory
  alias Ecto.Changeset
  alias Hap.Projects
  alias Hap.Projects.EventQuery
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

  describe "get_project!/1" do
    test "it returns the project identified by the given id" do
      %{id: project_id} = insert(:project)
      assert %Project{id: ^project_id} = Projects.get_project!(project_id)
    end

    test "it raises an Ecto.NoResultsError if the project does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project!(123)
      end
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

  describe "get_project_by_slug!/1" do
    test "it returns the project identified by the given id" do
      %{id: project_id, slug: slug} = insert(:project)
      assert %Project{id: ^project_id} = Projects.get_project_by_slug!(slug)
    end

    test "it raises an Ecto.NoResultsError if the project does not exist" do
      assert_raise Ecto.NoResultsError, fn ->
        Projects.get_project_by_slug!("nope")
      end
    end
  end

  describe "list_events_by_project/2" do
    test "it returns a list of event structs" do
      project = insert(:project)
      insert_pair(:event, project: project)

      assert [%Event{}, %Event{}] = Projects.list_events_by_project(project.id)
    end

    test "it only includes events for the specified project" do
      %{id: event_id, project_id: project_id} = insert(:event)
      insert(:event)

      assert [%Event{id: ^event_id}] = Projects.list_events_by_project(project_id)
    end

    test "it limits events to those with the given name" do
      project = insert(:project)
      insert(:event, name: "Order Returned", project: project)

      %{id: event_id} = insert(:event, name: "Order Received", project: project)

      assert [%Event{id: ^event_id}] =
               Projects.list_events_by_project(project.id, %EventQuery{name: "Order Received"})
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
