defmodule Hap.Repo.Migrations.CreateProjectsTable do
  use Ecto.Migration

  @table_name :projects

  def change do
    create table(@table_name) do
      add :organization_id, references(:organizations, on_delete: :delete_all), null: false
      add :name, :string, null: false
      add :api_key, :string, null: false
      timestamps()
    end

    create index(@table_name, [:organization_id])
    create unique_index(@table_name, [:api_key])
  end
end
