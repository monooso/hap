defmodule Hap.ApiTokens.ApiToken do
  @moduledoc false

  use Hap.Schema

  @type t() :: %__MODULE__{}

  schema "api_tokens" do
    field :name, :string
    field :token, :string

    timestamps(inserted_at: :created_at, updated_at: false)
  end

  @doc """
  Returns a changeset for inserting a new API token.
  """
  @spec insert_changeset(t() | Changeset.t(), map()) :: Changeset.t()
  def insert_changeset(struct_or_changeset, params) do
    permitted = [:name, :token]
    messages = [name: "The name must be a string", token: "The token must be a string"]

    struct_or_changeset
    |> cast_with_messages(params, permitted, messages: messages)
    |> validate_required([:name, :token])
    |> validate_name()
    |> validate_token()
  end

  defp validate_name(changeset) do
    changeset
    |> validate_length(:name, max: 255, message: "The name cannot be longer than 255 characters")
    |> unique_constraint(:name, message: "The name must be unique")
  end

  defp validate_token(changeset) do
    changeset
    |> validate_length(:token,
      max: 255,
      message: "The token cannot be longer than 255 characters"
    )
    |> unique_constraint(:token, message: "The token must be unique")
  end
end
