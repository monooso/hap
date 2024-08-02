defmodule Hap.Events.Event do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    belongs_to :organization, Hap.Organizations.Organization

    field :name, :string
    field :category, :string
    field :payload, :map

    timestamps(inserted_at: :logged_at, updated_at: false, type: :utc_datetime)
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:category, :name, :payload])
    |> validate_required([:category, :name])
  end
end
