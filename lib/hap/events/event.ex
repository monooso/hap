defmodule Hap.Events.Event do
  @moduledoc false

  use Hap.Schema

  @type t() :: %__MODULE__{}

  schema "events" do
    field :name, :string
    field :category, :string
    field :payload, :map

    timestamps(inserted_at: :logged_at, updated_at: false)
  end

  @doc """
  Returns a changeset for inserting a new event.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, params) do
    permitted = [:category, :name, :payload]

    messages = [
      category: "The category must be a string",
      name: "The name must be a string",
      payload: "The payload must be a map"
    ]

    struct_or_changeset
    |> cast_with_messages(params, permitted, messages: messages)
    |> validate_required([:category, :name])
    |> validate_category()
    |> validate_name()
  end

  defp validate_category(changeset) do
    validate_length(changeset, :category,
      max: 255,
      message: "The category cannot be longer than 255 characters"
    )
  end

  defp validate_name(changeset) do
    validate_length(changeset, :name,
      max: 255,
      message: "The name cannot be longer than 255 characters"
    )
  end
end
