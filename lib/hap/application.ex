defmodule Hap.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HapWeb.Telemetry,
      Hap.Repo,
      {DNSCluster, query: Application.get_env(:hap, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Hap.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Hap.Finch},
      # Start a worker by calling: Hap.Worker.start_link(arg)
      # {Hap.Worker, arg},
      # Start to serve requests, typically the last entry
      HapWeb.Endpoint
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
