defmodule HapWeb.Projects.BrowseLiveTest do
  use HapWeb.ConnCase
  import Hap.AccountsFixtures
  import Hap.Factory
  import Phoenix.LiveViewTest

  describe "logged-out user" do
    test "it redirects if the user is not logged-in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/projects")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "projects list" do
    setup %{conn: conn} do
      %{organization: organization} = user = user_fixture() |> Hap.Repo.preload(:organization)
      projects = insert_list(3, :project, organization: organization)

      [
        conn: log_in_user(conn, user),
        organization: organization,
        projects: projects,
        user: user
      ]
    end

    test "it displays a list of projects for the user's organization", %{
      conn: conn,
      projects: projects
    } do
      {:ok, _view, html} = live(conn, ~p"/projects")

      Enum.each(projects, fn project ->
        assert html =~ project.name
      end)
    end
  end

  describe "create project" do
    setup %{conn: conn} do
      [conn: log_in_user(conn, user_fixture())]
    end

    test "it displays an error when creating a project with invalid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/projects")

      result = view |> form("#create_project_form", %{}) |> render_submit()

      assert result =~ escape("can't be blank")
    end

    test "it creates a project with valid data", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/projects")

      {:ok, _view, html} =
        view
        |> form("#create_project_form", %{"project" => %{"name" => "Operation Petticoat"}})
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ escape("Project created")
      assert html =~ escape("Operation Petticoat")
    end
  end
end
