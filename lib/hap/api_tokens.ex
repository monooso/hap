defmodule Hap.ApiTokens do
  @moduledoc """
  Functions for managing API tokens.
  """

  alias Hap.ApiTokens.ApiToken
  alias Hap.Repo

  def create_api_token(params \\ %{}) do
    token = generate_unique_token()
    params |> Map.put("token", token) |> create_api_token_changeset() |> Repo.insert()
  end

  @doc """
  Returns a changeset for creating a new API token.
  """
  @spec create_api_token_changeset(map()) :: Ecto.Changeset.t()
  def create_api_token_changeset(params \\ %{}),
    do: ApiToken.insert_changeset(%ApiToken{}, params)

  @doc """
  Returns a list of API tokens.
  """
  @spec list_api_tokens() :: [ApiToken.t()]
  def list_api_tokens, do: Repo.all(ApiToken)

  @spec generate_unique_token() :: String.t()
  defp generate_unique_token, do: :crypto.strong_rand_bytes(16) |> Base.encode64()
end
