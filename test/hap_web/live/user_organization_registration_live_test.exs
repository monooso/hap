defmodule HapWeb.UserOrganizationRegistrationLiveTest do
  use HapWeb.ConnCase

  import Phoenix.LiveViewTest
  import Hap.AccountsFixtures
  import Hap.Factory

  describe "organization registration page" do
    setup do
      [user: user_fixture()]
    end

    test "it redirects if the user is not authenticated", %{conn: conn} do
      result =
        conn
        |> live(~p"/users/register_organization")
        |> follow_redirect(conn, "/users/log_in")

      assert {:ok, _conn} = result
    end

    test "it redirects if the user is already associated with an organization", %{
      conn: conn,
      user: user
    } do
      insert(:member, user: user)

      result =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register_organization")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "it renders the organization registration page", %{conn: conn, user: user} do
      {:ok, _lv, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register_organization")

      assert html =~ "Create your organization"
    end

    test "it renders errors for invalid data", %{conn: conn, user: user} do
      {:ok, lv, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/users/register_organization")

      result =
        lv
        |> form("#organization_form", organization: %{name: ""})
        |> render_submit()

      assert result =~ "Create your organization"
      assert result =~ escape("can't be blank")
    end

    @tag :skip
    test "it creates an organization and redirects to the dashboard", %{conn: _conn, user: _user} do
    end
  end
end
