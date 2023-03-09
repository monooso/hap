defmodule HapWeb.Hooks.Project do
  @moduledoc """
  on_mount hooks for project LiveViews.
  """

  use HapWeb, :verified_routes
  import Phoenix.Component, only: [assign: 3]
  alias Hap.Projects

  def on_mount(:fetch_current_project, %{"project_slug" => slug}, _session, socket) do
    {:cont, assign(socket, :current_project, Projects.get_project_by_slug!(slug))}
  end

  def on_mount(
        :require_project_access,
        _params,
        _session,
        %{assigns: %{current_user: user, current_project: project}} = socket
      ) do
    if user.organization_id == project.organization_id do
      {:cont, socket}
    else
      socket =
        socket
        |> Phoenix.LiveView.put_flash(:error, "You do not have access to this project.")
        |> Phoenix.LiveView.redirect(to: ~p"/projects")

      {:halt, socket}
    end
  end
end
