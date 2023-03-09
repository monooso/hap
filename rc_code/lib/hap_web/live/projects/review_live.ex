defmodule HapWeb.Projects.ReviewLive do
  @moduledoc false

  use HapWeb, :live_view
  alias Hap.Projects
  alias Hap.Projects.EventQuery

  on_mount {HapWeb.Hooks.Project, :fetch_current_project}
  on_mount {HapWeb.Hooks.Project, :require_project_access}

  @impl true
  def mount(_params, _session, socket), do: {:ok, socket}

  @impl true
  def render(assigns) do
    ~H"""
    <form data-test-id="filter-form" phx-submit="filter">
      <div>
        <label for="name">Name</label>
        <input type="text" name="name" value={@filter.name} />
      </div>
      <div>
        <label for="message">Message</label>
        <input type="text" name="message" value={@filter.message} />
      </div>
      <div>
        <label for="tags">Tags</label>
        <input type="text" name="tags" value={Enum.join(@filter.tags, ",")} />
      </div>
      <button>Filter</button>
    </form>

    <ol class="space-y-4">
      <li :for={event <- @events}>
        <div><%= event.name %></div>
        <div><%= event.message %></div>
        <div><%= Enum.join(event.tags, ", ") %></div>
        <div><%= event.inserted_at %></div>
      </li>
    </ol>
    """
  end

  @impl true
  def handle_event("filter", params, %{assigns: %{current_project: project}} = socket) do
    {:noreply, push_patch(socket, to: ~p"/projects/#{project}/review?#{params}")}
  end

  @impl true
  def handle_params(params, _uri, %{assigns: %{current_project: project}} = socket) do
    filter = %EventQuery{
      message: params["message"] || "",
      name: params["name"] || "",
      tags: (params["tags"] || "") |> String.split(",")
    }

    {:noreply,
     socket
     |> assign(events: Projects.list_events_by_project(project, filter))
     |> assign(filter: filter)
     |> assign(project: project)}
  end
end
