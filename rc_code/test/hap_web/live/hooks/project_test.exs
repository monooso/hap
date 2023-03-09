defmodule HapWeb.Hooks.ProjectTest do
  @moduledoc false

  use Hap.DataCase, async: true
  use HapWeb, :verified_routes
  import Hap.Factory
  alias HapSchemas.Projects.Project
  alias HapWeb.Hooks.Project, as: Hooks
  alias Phoenix.LiveView.Socket

  describe "fetch_current_project/3" do
    test "it adds the current project to the socket" do
      %{id: id, slug: slug} = insert(:project)
      params = %{"project_slug" => slug}

      assert {:cont, %Socket{assigns: %{current_project: %Project{id: ^id}}}} =
               Hooks.on_mount(:fetch_current_project, params, nil, %Socket{})
    end

    test "it raises an Ecto.NoResultsError if the project does not exist" do
      assert_raise(Ecto.NoResultsError, fn ->
        Hooks.on_mount(:fetch_current_project, %{"project_slug" => "nope"}, nil, %Socket{})
      end)
    end

    test "it raises a FunctionClauseError if the parameters map does not contain a project id" do
      assert_raise(FunctionClauseError, fn ->
        Hooks.on_mount(:fetch_current_project, %{}, nil, %Socket{})
      end)
    end
  end

  describe "require_project_access/3" do
    setup do
      user = insert(:user)
      allowed_project = insert(:project, organization: user.organization)
      disallowed_project = insert(:project)

      allowed_socket = %Socket{
        assigns: %{
          __changed__: %{},
          current_project: allowed_project,
          current_user: user,
          flash: %{}
        }
      }

      disallowed_socket = %Socket{
        assigns: %{
          __changed__: %{},
          current_project: disallowed_project,
          current_user: user,
          flash: %{}
        }
      }

      [allowed_socket: allowed_socket, disallowed_socket: disallowed_socket]
    end

    test "it continues if the current user has access to the current project", %{
      allowed_socket: socket
    } do
      assert {:cont, ^socket} = Hooks.on_mount(:require_project_access, nil, nil, socket)
    end

    test "it halts if the current user does not have access to the current project", %{
      disallowed_socket: socket
    } do
      assert {:halt, _updated_socket} = Hooks.on_mount(:require_project_access, nil, nil, socket)
    end

    test "it redirects to /projects if the current user does not have access to the current project",
         %{disallowed_socket: socket} do
      assert {:halt, updated_socket} = Hooks.on_mount(:require_project_access, nil, nil, socket)

      redirect_path = ~p"/projects"
      assert %Socket{redirected: {:redirect, %{to: ^redirect_path}}} = updated_socket
    end

    test "it displays a flash message if the current user does not have access to the current project",
         %{disallowed_socket: socket} do
      assert {:halt, updated_socket} = Hooks.on_mount(:require_project_access, nil, nil, socket)

      assert %Socket{assigns: %{flash: %{"error" => "You do not have access to this project."}}} =
               updated_socket
    end
  end
end
