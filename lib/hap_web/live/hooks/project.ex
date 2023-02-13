defmodule HapWeb.Hooks.Project do
  @moduledoc """
  on_mount hooks for project LiveViews.
  """

  import Phoenix.Component, only: [assign: 3]
  alias Hap.Projects

  def on_mount(:fetch_current_project, %{"project_id" => project_id}, _session, socket) do
    {:cont, assign(socket, :current_project, Projects.get_project!(project_id))}
  end
end
