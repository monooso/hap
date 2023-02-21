defmodule HapWeb.PageController do
  use HapWeb, :controller

  def home(conn, _params) do
    render(conn, :home, layout: {HapWeb.Layouts, :guest})
  end
end
