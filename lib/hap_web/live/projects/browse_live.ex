defmodule HapWeb.Projects.BrowseLive do
  @moduledoc false

  use HapWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket |> assign_projects()}
  end

  defp assign_projects(socket) do
    assign(socket, :projects, [])
  end
end
