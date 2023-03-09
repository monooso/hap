defmodule HapWeb.Api.Events do
  @moduledoc false

  use HapWeb, :controller
  import HapWeb.ApiAuth
  alias Ecto.Changeset
  alias Hap.Projects

  plug(:fetch_current_project)
  plug(:require_current_project)

  def create(%{assigns: %{current_project: project}} = conn, params) do
    case Projects.create_event(project, params) do
      {:ok, _event} ->
        send_resp(conn, :created, "Event created")

      {:error, %Changeset{} = changeset} ->
        send_resp(conn, :bad_request, Changeset.traverse_errors(changeset, & &1))
    end
  end
end
