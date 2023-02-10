defmodule Hap.Repo.Migrations.CreateEventsTable do
  use Ecto.Migration

  @table_name :events

  def change do
    create table(@table_name) do
      add :project_id, references(:projects, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :message, :string
      add :tags, {:array, :string}
      add :metadata, :map
      timestamps()
    end

    create index(@table_name, [:project_id])
    create index(@table_name, [:name])
  end
end
