defmodule Hap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      HapWeb.Telemetry,
      # Start the Ecto repository
      Hap.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Hap.PubSub},
      # Start Finch
      {Finch, name: Hap.Finch},
      # Start the Endpoint (http/https)
      HapWeb.Endpoint
      # Start a worker by calling: Hap.Worker.start_link(arg)
      # {Hap.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Hap.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HapWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
