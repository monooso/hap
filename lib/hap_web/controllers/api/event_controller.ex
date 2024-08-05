defmodule HapWeb.Api.EventController do
  use HapWeb, :controller

  alias Hap.Events

  def new(conn, %{"data" => params}) do
    {:ok, event} = Events.create_event(params)

    conn |> put_status(:created) |> render(:show, event: event)
  end
end
