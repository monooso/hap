defmodule Hap.Repo.Migrations.CreateUsersTable do
  use Ecto.Migration

  @table :users

  def change do
    create table(@table) do
      timestamps()

      add :email, :citext, null: false
      add :hashed_password, :string, null: false
      add :confirmed_at, :utc_datetime
    end

    create unique_index(@table, [:email])
  end
end
