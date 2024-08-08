defmodule Hap.ApiTokensTest do
  use Hap.DataCase, async: true

  alias Hap.ApiTokens
  alias Hap.ApiTokens.ApiToken

  describe "create_api_token/1" do
    setup do
      [params: %{"name" => "Testing API token"}]
    end

    test "it returns an {:ok, api_token} tuple when given valid params", %{params: params} do
      assert {:ok, %ApiToken{id: id}} = ApiTokens.create_api_token(params)
      assert id
    end

    test "it generates the token", %{params: params} do
      assert {:ok, %ApiToken{token: token}} = ApiTokens.create_api_token(params)
      assert token |> is_binary()
    end

    test "it returns an {:error, changeset} tuple when given invalid params" do
      assert {:error, %Ecto.Changeset{}} = ApiTokens.create_api_token(%{})
    end
  end

  describe "create_api_token_changeset/1" do
    test "it returns a Changeset for creating an API token" do
      assert %Ecto.Changeset{data: %ApiToken{}} = ApiTokens.create_api_token_changeset(%{})
    end
  end

  describe "list_api_tokens/0" do
    test "it returns a list of API tokens" do
      insert_list(2, :api_token)
      assert [%ApiToken{}, %ApiToken{}] = ApiTokens.list_api_tokens()
    end
  end
end
