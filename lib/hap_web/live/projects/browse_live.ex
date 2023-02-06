defmodule HapWeb.Projects.BrowseLive do
  @moduledoc false

  use HapWeb, :live_view
  alias Hap.Projects

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_changeset() |> assign_projects()}
  end

  @impl true
  def handle_event(
        "create_project",
        %{"project" => params},
        %{assigns: %{current_user: user}} = socket
      ) do
    params = Map.put(params, "organization_id", user.organization_id)

    case Projects.create_project(params) do
      {:ok, _project} ->
        {:noreply,
         socket
         |> put_flash(:info, "Project created")
         |> push_redirect(to: ~p"/projects")}

      {:error, changeset} ->
        {:noreply, socket |> assign_changeset(changeset)}
    end
  end

  defp assign_changeset(socket, changeset \\ Projects.create_project_changeset(%{})),
    do: assign(socket, :changeset, changeset)

  defp assign_projects(%{assigns: %{current_user: user}} = socket),
    do: assign(socket, :projects, Projects.list_projects_by_organization(user.organization_id))
end
