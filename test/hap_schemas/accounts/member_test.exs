defmodule HapSchemas.Accounts.MemberTest do
  use Hap.DataCase
  import Hap.Factory
  alias Ecto.Changeset
  alias HapSchemas.Accounts.Member

  describe "insert_changeset/2" do
    setup do
      [
        attrs: %{
          organization_id: insert(:organization) |> Map.get(:id),
          user_id: insert(:user) |> Map.get(:id)
        }
      ]
    end

    test "it returns a valid changeset when given valid data", %{attrs: attrs} do
      assert %Changeset{valid?: true} = Member.insert_changeset(%Member{}, attrs)
    end

    test "it validates that the organization_id is given", %{attrs: attrs} do
      attrs = Map.delete(attrs, :organization_id)
      changeset = Member.insert_changeset(%Member{}, attrs)

      assert %{organization_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "it validates that the user_id is given", %{attrs: attrs} do
      attrs = Map.delete(attrs, :user_id)
      changeset = Member.insert_changeset(%Member{}, attrs)

      assert %{user_id: ["can't be blank"]} = errors_on(changeset)
    end

    test "the organization_id must refer to a valid organization", %{attrs: attrs} do
      attrs = %{attrs | organization_id: 123}

      {:error, changeset} =
        %Member{}
        |> Member.insert_changeset(attrs)
        |> Hap.Repo.insert()

      assert %{organization: ["does not exist"]} = errors_on(changeset)
    end

    test "the user_id must refer to a valid user", %{attrs: attrs} do
      attrs = %{attrs | user_id: 123}

      {:error, changeset} =
        %Member{}
        |> Member.insert_changeset(attrs)
        |> Hap.Repo.insert()

      assert %{user: ["does not exist"]} = errors_on(changeset)
    end
  end
end
