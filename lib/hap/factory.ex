defmodule Hap.Factory do
  @moduledoc """
  Test factories.
  """

  use ExMachina.Ecto, repo: Hap.Repo

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
      end,
      payload: fn
        %{category: "audit"} -> %{user_id: Enum.random(1..10_000)}
        %{category: "orders"} -> %{order_id: Enum.random(1..10_000)}
        %{category: "shipping"} -> %{shipment_id: Enum.random(1..10_000)}
      end
    }
  end

  def organization_factory do
    %Hap.Organizations.Organization{
      name: sequence(:name, &"Organization #{&1}")
    }
  end
end
