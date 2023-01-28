defmodule Hap.Accounts.Organization do
  use Ecto.Schema

  schema "organizations" do
    field :name, :string

    has_many :users, Hap.Accounts.User

    timestamps()
  end
end
