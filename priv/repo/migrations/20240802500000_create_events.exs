defmodule Hap.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  @table :events

  def change do
    create table(@table) do
      timestamps(inserted_at: :logged_at, updated_at: false, type: :utc_datetime)

      add :category, :string, null: false
      add :name, :string, null: false
      add :payload, :map
    end

    create index(@table, [:category])
  end
end
