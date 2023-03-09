defmodule HapWeb.Projects.ReviewLiveTest do
  use HapWeb.ConnCase
  import Hap.AccountsFixtures
  import Hap.Factory
  import Phoenix.LiveViewTest

  describe "logged-out user" do
    test "it redirects if the user is not logged-in", %{conn: conn} do
      project = insert(:project)

      assert {:error, redirect} = live(conn, ~p"/projects/#{project}/review")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/users/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "logged-in interloper" do
    test "it redirects to /projects if the logged-in user does not have access to the project", %{
      conn: conn
    } do
      conn = log_in_user(conn, user_fixture())
      project = insert(:project)

      assert {:error, redirect} = live(conn, ~p"/projects/#{project}/review")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/projects"
      assert %{"error" => "You do not have access to this project."} = flash
    end
  end

  describe "review project events" do
    setup %{conn: conn} do
      %{organization: organization} = user = user_fixture() |> Hap.Repo.preload(:organization)

      project = insert(:project, organization: organization)

      [
        conn: log_in_user(conn, user),
        project: project,
        user: user
      ]
    end

    test "it displays all of the events for the current project", %{conn: conn, project: project} do
      insert(:event, project: project, name: "My first event")
      insert(:event, project: project, name: "My second event")
      insert(:event, name: "Your first event")

      {:ok, _view, html} = live(conn, ~p"/projects/#{project}/review")

      assert html =~ "My first event"
      assert html =~ "My second event"
      refute html =~ "Your first event"
    end

    test "the user can filter the events by name", %{conn: conn, project: project} do
      insert(:event, project: project, name: "Event alpha")
      insert(:event, project: project, name: "Event bravo")

      {:ok, view, html} = live(conn, ~p"/projects/#{project}/review")

      assert html =~ "Event alpha"
      assert html =~ "Event bravo"

      html =
        view
        |> form("[data-test-id='filter-form']", %{"name" => "alpha"})
        |> render_submit()

      assert html =~ "Event alpha"
      refute html =~ "Event bravo"
    end

    test "the user can filter the events by message", %{conn: conn, project: project} do
      insert(:event, project: project, message: "It was the best of times")
      insert(:event, project: project, message: "It was the worst of times")

      {:ok, view, html} = live(conn, ~p"/projects/#{project}/review")

      assert html =~ "It was the worst of times"
      assert html =~ "It was the best of times"

      html =
        view
        |> form("[data-test-id='filter-form']", %{"message" => "worst"})
        |> render_submit()

      assert_patched(view, ~p"/projects/#{project}/review?#{[message: "worst"]}")
      assert html =~ "It was the worst of times"
      refute html =~ "It was the best of times"
    end

    test "the user can filter the events by comma-delimited tags", %{conn: conn, project: project} do
      insert(:event, project: project, name: "Sale 01", tags: ["kpi", "sales"])
      insert(:event, project: project, name: "Return 01", tags: ["kpi", "returns"])
      insert(:event, project: project, name: "Sale 02", tags: ["kpi", "sales"])

      {:ok, view, html} = live(conn, ~p"/projects/#{project}/review")

      assert html =~ "Sale 01"
      assert html =~ "Sale 02"
      assert html =~ "Return 01"

      html =
        view
        |> form("[data-test-id='filter-form']", %{"tags" => "kpi, sales"})
        |> render_submit()

      assert html =~ "Sale 01"
      assert html =~ "Sale 02"
      refute html =~ "Return 01"
    end

    test "the url contains the filters", %{conn: conn, project: project} do
      insert(:event, project: project)
      insert(:event, project: project)

      filters = %{"message" => "Hola", "name" => "Cleetus", "tags" => "alpha, bravo"}

      {:ok, view, html} = live(conn, ~p"/projects/#{project}/review")

      view
      |> form("[data-test-id='filter-form']", filters)
      |> render_submit()

      assert_patched(view, ~p"/projects/#{project}/review?#{filters}")
    end
  end
end
