defmodule Hap.Repo.Migrations.CreateUsersTokensTable do
  use Ecto.Migration

  @table :users_tokens

  def change do
    create table(@table) do
      timestamps(updated_at: false)

      add :user_id, references(:users, on_delete: :delete_all), null: false

      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
    end

    create index(@table, [:user_id])
    create unique_index(@table, [:context, :token])
  end
end
