defmodule Hap.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  @table :organizations

  def change do
    create table(@table) do
      timestamps(type: :utc_datetime)

      add :name, :string, null: false
    end
  end
end
