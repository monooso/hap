defmodule HapWeb.ApiAuth do
  @moduledoc false

  import Plug.Conn
  alias Hap.Projects
  alias Plug.Conn

  @doc """
  Fetches the project associated with the bearer token API key, and assigns it to the :project key.
  """
  @spec fetch_current_project(Conn.t(), keyword()) :: Conn.t()
  def fetch_current_project(conn, _opts) do
    {project_api_key, conn} = ensure_project_api_key(conn)
    project = project_api_key && Projects.get_project_by_api_key(project_api_key)
    assign(conn, :current_project, project)
  end

  @doc """
  Requires that the project associated with the bearer token API key is present.
  """
  @spec require_current_project(Conn.t(), keyword()) :: Conn.t()
  def require_current_project(%{assigns: %{current_project: project}} = conn, _opts)
      when not is_nil(project),
      do: conn

  def require_current_project(conn, _opts),
    do: conn |> send_resp(:unauthorized, "Unauthorized")

  @spec ensure_project_api_key(Conn.t()) :: {String.t() | nil, Conn.t()}
  defp ensure_project_api_key(conn),
    do: {get_bearer_token(conn), conn}

  @spec get_bearer_token(Conn.t()) :: String.t() | nil
  defp get_bearer_token(conn) do
    case get_req_header(conn, "authorization") do
      ["Bearer " <> token] -> token
      _ -> nil
    end
  end
end
