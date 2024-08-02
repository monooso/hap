defmodule Hap.Organizations.Organization do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "organizations" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(organization, attrs) do
    organization
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
