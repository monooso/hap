defmodule HapWeb.Events.BrowseLive do
  @moduledoc false

  use HapWeb, :live_view

  on_mount {HapWeb.Hooks.Project, :fetch_current_project}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket |> assign_events()}
  end

  defp assign_events(%{assigns: %{current_project: project}} = socket) do
    assign(socket, :events, Hap.Projects.list_events_by_project(project))
  end
end
