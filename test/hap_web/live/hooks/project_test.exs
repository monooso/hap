defmodule HapWeb.Hooks.ProjectTest do
  @moduledoc false

  use Hap.DataCase, async: true
  import Hap.Factory
  alias HapSchemas.Projects.Project
  alias HapWeb.Hooks.Project, as: Hooks
  alias Phoenix.LiveView.Socket

  describe "fetch_current_project/3" do
    test "it adds the current project to the socket" do
      %{id: project_id} = insert(:project)
      params = %{"project_id" => project_id}

      assert {:cont, %Socket{assigns: %{current_project: %Project{id: ^project_id}}}} =
               Hooks.on_mount(:fetch_current_project, params, nil, %Socket{})
    end

    test "it raises an Ecto.NoResultsError if the project does not exist" do
      assert_raise(Ecto.NoResultsError, fn ->
        Hooks.on_mount(:fetch_current_project, %{"project_id" => 123}, nil, %Socket{})
      end)
    end

    test "it raises a FunctionClauseError if the parameters map does not contain a project id" do
      assert_raise(FunctionClauseError, fn ->
        Hooks.on_mount(:fetch_current_project, %{}, nil, %Socket{})
      end)
    end
  end
end
