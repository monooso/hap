defmodule HapWeb.Projects.ReadLive do
  @moduledoc false

  use HapWeb, :live_view
  alias Hap.Projects
  alias HapSchemas.Ui.EventQuery

  on_mount {HapWeb.Hooks.Project, :fetch_current_project}
  on_mount {HapWeb.Hooks.Project, :require_project_access}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event(
        "filter_events",
        %{"event_query" => params},
        %{assigns: %{current_project: project}} = socket
      ) do
    {:noreply, socket |> push_patch(to: ~p"/projects/#{project}?#{params}")}
  end

  @impl true
  def handle_params(params, _session, socket) do
    {:noreply,
     socket
     |> assign_changeset(params)
     |> assign_events()}
  end

  defp assign_changeset(socket, params),
    do: assign(socket, :changeset, Projects.event_query_changeset(%EventQuery{}, params))

  defp assign_events(%{assigns: %{changeset: changeset, current_project: project}} = socket) do
    filters = Ecto.Changeset.apply_changes(changeset)
    assign(socket, :events, Projects.list_events_by_project(project, filters))
  end
end
