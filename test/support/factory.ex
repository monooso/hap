defmodule Hap.Factory do
  @moduledoc "Test helper factory functions."

  use ExMachina.Ecto, repo: Hap.Repo

  # def event_factory do
  #   %HapSchemas.Projects.Event{
  #     message: "A new event has occurred",
  #     metadata: %{
  #       customer_id: Enum.random(1..1_000_000),
  #       order_id: Enum.random(1..1_000_000)
  #     },
  #     name: "Event" |> make_unique(),
  #     project: build(:project),
  #     tags: ["alpha", "bravo", "charlie"]
  #   }
  # end

  def member_factory do
    %HapSchemas.Accounts.Member{
      organization: build(:organization),
      user: build(:user)
    }
  end

  def organization_factory do
    %HapSchemas.Accounts.Organization{
      name: "Organization" |> make_unique()
    }
  end

  # def project_factory do
  #   %HapSchemas.Projects.Project{
  #     api_key: Ecto.UUID.generate(),
  #     name: "Project" |> make_unique(),
  #     organization: build(:organization),
  #     slug: Hap.Helpers.Slugger.generate_random_slug()
  #   }
  # end

  def user_factory do
    %HapSchemas.Accounts.User{
      email: ("user" |> make_unique()) <> "@example.com",
      hashed_password: Bcrypt.hash_pwd_salt("password")
    }
  end

  @spec make_unique(String.t()) :: String.t()
  defp make_unique(string) when is_binary(string) do
    "#{string}#{System.unique_integer([:positive, :monotonic])}"
  end
end
