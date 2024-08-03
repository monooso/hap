defmodule Hap.Organizations.Organization do
  @moduledoc false

  use Hap.Schema

  @type t() :: %__MODULE__{}

  schema "organizations" do
    field :name, :string

    timestamps()
  end

  @doc """
  Returns a changeset for inserting a new organization.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, params) do
    permitted = [:name]
    messages = [name: "The name must be a string"]

    struct_or_changeset
    |> cast_with_messages(params, permitted, messages: messages)
    |> validate_required([:name])
    |> validate_name()
  end

  defp validate_name(changeset) do
    validate_length(changeset, :name,
      max: 255,
      message: "The name cannot be longer than 255 characters"
    )
  end
end
