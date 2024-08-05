defmodule HapWeb.FeatureCase do
  @moduledoc """
  Setup for feature tests powered by PhoenixTest.

  If you are using PostgreSQL, you can run database tests asynchronously by setting
  `use Hap.FeatureCase, async: true`. This option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      use HapWeb, :verified_routes

      import HapWeb.FeatureCase

      import PhoenixTest
    end
  end

  setup tags do
    pid = Ecto.Adapters.SQL.Sandbox.start_owner!(Hap.Repo, shared: not tags[:async])
    on_exit(fn -> Ecto.Adapters.SQL.Sandbox.stop_owner(pid) end)

    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
