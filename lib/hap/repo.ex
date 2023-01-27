defmodule Hap.Repo do
  use Ecto.Repo,
    otp_app: :hap,
    adapter: Ecto.Adapters.Postgres
end
