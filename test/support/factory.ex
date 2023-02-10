defmodule Hap.Factory do
  @moduledoc "Test helper factory functions."

  use ExMachina.Ecto, repo: Hap.Repo

  def organization_factory do
    %HapSchemas.Accounts.Organization{
      name: "Organization" |> make_unique()
    }
  end

  def project_factory do
    %HapSchemas.Projects.Project{
      api_key: Ecto.UUID.generate(),
      name: "Project" |> make_unique(),
      organization: build(:organization)
    }
  end

  @spec make_unique(String.t()) :: String.t()
  defp make_unique(string) when is_binary(string) do
    "#{string}#{System.unique_integer([:positive, :monotonic])}"
  end
end
