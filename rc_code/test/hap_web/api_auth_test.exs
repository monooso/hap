defmodule HapWeb.ApiAuthTest do
  use HapWeb.ConnCase, async: true
  import Hap.Factory
  alias HapSchemas.Projects.Project
  alias HapWeb.ApiAuth
  alias Plug.Conn

  describe "fetch_current_project/2" do
    test "it assigns the project to the conn", %{conn: conn} do
      %{api_key: api_key, id: project_id} = insert(:project)
      conn = conn |> Conn.put_req_header("authorization", "Bearer " <> api_key)

      assert %{assigns: %{current_project: %Project{id: ^project_id}}} =
               ApiAuth.fetch_current_project(conn, [])
    end

    test "it assigns nil if there is no bearer token", %{conn: conn} do
      assert %Conn{assigns: %{current_project: project}} = ApiAuth.fetch_current_project(conn, [])
      assert is_nil(project)
    end

    test "it assigns nil if the project cannot be found", %{conn: conn} do
      conn = conn |> Conn.put_req_header("authorization", "Bearer abc123")

      assert %Conn{assigns: %{current_project: project}} = ApiAuth.fetch_current_project(conn, [])
      assert is_nil(project)
    end
  end

  describe "require_current_project/2" do
    test "it returns the connection if the current_project is not nil", %{conn: conn} do
      conn = Conn.assign(conn, :current_project, %Project{})
      assert %Conn{status: status} = ApiAuth.require_current_project(conn, [])
      assert is_nil(status)
    end

    test "it returns a 401 if the current_project is nil", %{conn: conn} do
      assert %Conn{status: 401} = ApiAuth.require_current_project(conn, [])
    end
  end
end
