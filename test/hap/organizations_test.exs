defmodule Hap.OrganizationsTest do
  use Hap.DataCase, async: true

  alias Hap.Organizations
  alias Hap.Organizations.Organization

  describe "create_organization/1" do
    setup do
      [params: %{"name" => "Hap Industries"}]
    end

    test "it returns an {:ok, organization} tuple when given valid params", %{params: params} do
      assert {:ok, %Organization{}} = Organizations.create_organization(params)
    end

    test "it creates an organization with the given params", %{params: params} do
      {:ok, organization} = Organizations.create_organization(params)

      assert organization.id
      assert organization.name == params["name"]
    end

    test "it returns an {:error, changeset} tuple when given invalid params" do
      assert {:error, %Ecto.Changeset{}} = Organizations.create_organization(%{})
    end
  end

  describe "create_organization_changeset/1" do
    test "it returns an Ecto.Changeset struct" do
      assert %Ecto.Changeset{data: %Organization{}} =
               Organizations.create_organization_changeset(%{})
    end
  end

  describe "list_organizations/0" do
    test "it returns a list of organizations, ordered by name" do
      insert(:organization, name: "Zulu")
      insert(:organization, name: "Alpha")

      assert [%Organization{name: "Alpha"}, %Organization{name: "Zulu"}] =
               Organizations.list_organizations()
    end
  end
end
