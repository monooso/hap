defmodule Hap.Repo.Migrations.CreateApiTokens do
  use Ecto.Migration

  @table :api_tokens

  def change do
    create table(@table) do
      timestamps(inserted_at: :created_at, updated_at: false)

      add :name, :string, null: false
      add :token, :string, null: false
    end

    create unique_index(@table, [:name])
    create unique_index(@table, [:token])
  end
end
