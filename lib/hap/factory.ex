defmodule Hap.Factory do
  @moduledoc """
  Test factories.
  """

  use ExMachina.Ecto, repo: Hap.Repo

  @doc """
  Utility function used by various tests. Ported from the generated `AccountsFixtures` module.
  """
  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end

  def api_token_factory do
    %Hap.ApiTokens.ApiToken{
      name: sequence(:name, &"API token #{&1}"),
      token: sequence(:token, &"api_token_#{&1}")
    }
  end

  def event_factory do
    %Hap.Events.Event{
      category: Enum.random(["audit", "orders", "shipping"]),
      name: fn
        %{category: "audit"} ->
          Enum.random([
            "user.joined_organization",
            "user.left_organization",
            "user.logged_in",
            "user.logged_out"
          ])

        %{category: "orders"} ->
          Enum.random(["cancelled", "created", "delivered", "refunded", "returned", "shipped"])

        %{category: "shipping"} ->
          Enum.random([
            "preparing_shipment",
            "shipment_prepared",
            "awaiting_courier_collection",
            "collected_by_courier",
            "delivered"
          ])

        _ ->
          sequence(:name, &"event_name_#{&1}")
      end,
      payload: fn
        %{category: "audit"} -> %{user_id: Enum.random(1..10_000)}
        %{category: "orders"} -> %{order_id: Enum.random(1..10_000)}
        %{category: "shipping"} -> %{shipment_id: Enum.random(1..10_000)}
        _ -> %{}
      end
    }
  end

  def user_factory(attrs) do
    password = Map.get(attrs, :password, "very_secure_password")
    attrs = Map.delete(attrs, :password)

    %Hap.Accounts.User{
      email: "user_#{System.unique_integer()}@example.com",
      hashed_password: fn -> Bcrypt.hash_pwd_salt(password) end
    }
    |> merge_attributes(attrs)
    |> evaluate_lazy_attributes()
  end
end
