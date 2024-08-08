defmodule Hap.ApiTokens.ApiTokenTest do
  use Hap.DataCase, async: true

  alias Hap.ApiTokens.ApiToken

  describe "insert_changeset/2" do
    setup do
      [
        params: %{
          "name" => "Testing API token",
          "token" => System.unique_integer() |> Integer.to_string()
        }
      ]
    end

    test "it returns a valid changeset when given valid params", %{params: params} do
      assert params |> insert_changeset() |> valid_changeset?()
    end

    test "it returns an invalid changeset when given invalid params" do
      refute %{} |> insert_changeset() |> valid_changeset?()
    end

    test "it validates the name parameter", %{params: params} do
      # Missing
      changeset = params |> Map.delete("name") |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["Please specify the name"]} = errors_on(changeset)

      # Empty string
      changeset = %{params | "name" => ""} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["Please specify the name"]} = errors_on(changeset)

      # Not a string
      changeset = %{params | "name" => 123} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{name: ["The name must be a string"]} = errors_on(changeset)

      # Too long
      changeset = %{params | "name" => String.duplicate("x", 256)} |> insert_changeset()
      refute valid_changeset?(changeset)

      assert %{name: ["The name cannot be longer than 255 characters"]} =
               errors_on(changeset)

      # Not unique
      insert(:api_token, name: "FIRST")

      {:error, changeset} =
        %{params | "name" => "FIRST"} |> insert_changeset() |> perform_insert()

      assert %{name: ["The name must be unique"]} = errors_on(changeset)
    end

    test "it validates the token parameter", %{params: params} do
      # Missing
      changeset = params |> Map.delete("token") |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{token: ["Please specify the token"]} = errors_on(changeset)

      # Empty string
      changeset = %{params | "token" => ""} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{token: ["Please specify the token"]} = errors_on(changeset)

      # Not a string
      changeset = %{params | "token" => 123} |> insert_changeset()
      refute valid_changeset?(changeset)
      assert %{token: ["The token must be a string"]} = errors_on(changeset)

      # Too long
      changeset = %{params | "token" => String.duplicate("x", 256)} |> insert_changeset()
      refute valid_changeset?(changeset)

      assert %{token: ["The token cannot be longer than 255 characters"]} =
               errors_on(changeset)

      # Not unique
      insert(:api_token, token: "taken")

      {:error, changeset} =
        %{params | "token" => "taken"} |> insert_changeset() |> perform_insert()

      assert %{token: ["The token must be unique"]} = errors_on(changeset)
    end
  end

  defp insert_changeset(params), do: ApiToken.insert_changeset(%ApiToken{}, params)

  defp perform_insert(changeset), do: Hap.Repo.insert(changeset)
end
