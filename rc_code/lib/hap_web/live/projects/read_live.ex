defmodule HapWeb.Projects.ReadLive do
  @moduledoc false

  use HapWeb, :live_view

  on_mount {HapWeb.Hooks.Project, :fetch_current_project}
  on_mount {HapWeb.Hooks.Project, :require_project_access}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign_page_title(socket)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <h1><%= @page_title %></h1>
    <ul>
      <li>
        <.link navigate={~p"/projects/#{@current_project}/review"}>Review</.link>
      </li>
    </ul>
    """
  end

  defp assign_page_title(%{assigns: %{current_project: project}} = socket),
    do: assign(socket, :page_title, project.name)
end
