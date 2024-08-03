defmodule Hap.ChangesetTest do
  use Hap.DataCase, async: true

  import Hap.Changeset, only: [validate_required: 2]

  describe "validate_required/2" do
    test "it returns a valid changeset when given valid data" do
      assert %{age: 42, name: "JimBob"}
             |> make_changeset()
             |> validate_required([:age, :name])
             |> valid_changeset?()
    end

    test "it validates that the given field is present" do
      refute %{age: 42} |> make_changeset() |> validate_required(:name) |> valid_changeset?()
    end

    test "it validates that the given fields are present" do
      refute %{} |> make_changeset() |> validate_required([:age, :name]) |> valid_changeset?()
    end

    test "it generates a user-friendly error message containing the field name" do
      changeset = %{} |> make_changeset() |> validate_required([:age, :name])

      assert %{age: ["Please specify the age"], name: ["Please specify the name"]} =
               errors_on(changeset)
    end

    test "it removes the `_id` suffix from relationship field names when generating an error message" do
      changeset = %{} |> make_changeset() |> validate_required([:family_id])

      assert %{family_id: ["Please specify the family"]} = errors_on(changeset)
    end

    test "it does not override the `Ecto.Changeset.validate_required/3` function" do
      import Ecto.Changeset, only: [validate_required: 3]

      changeset = %{} |> make_changeset() |> validate_required([:age], message: "Just a number")

      assert %{age: ["Just a number"]} = errors_on(changeset)
    end
  end

  defp make_changeset(data, changes \\ %{}) do
    types = %{age: :integer, family_id: :integer, name: :string}
    Ecto.Changeset.change({data, types}, changes)
  end
end
