defmodule Hap.Factory do
  use ExMachina.Ecto, repo: Hap.Repo

  def organization_factory do
    %Hap.Accounts.Organization{
      name: "Organization" |> make_unique()
    }
  end

  @spec make_unique(String.t()) :: String.t()
  defp make_unique(string) when is_binary(string) do
    "#{string}#{System.unique_integer([:positive, :monotonic])}"
  end
end
