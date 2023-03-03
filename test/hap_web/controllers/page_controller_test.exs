defmodule HapWeb.PageControllerTest do
  use HapWeb.ConnCase, async: true
  import Hap.AccountsFixtures

  describe "GET /" do
    test "it redirects to the login page", %{conn: conn} do
      conn = get(conn, ~p"/")
      assert redirected_to(conn) == ~p"/users/log_in"
    end

    test "it displays the dashboard if the user is logged-in", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> get(~p"/")
      assert html_response(conn, 200) =~ "There's no place like it"
    end
  end
end
