defmodule Hap.Repo.Migrations.CreateMembersTable do
  use Ecto.Migration

  def change do
    create table(:members) do
      add(:organization_id, references(:organizations, on_delete: :delete_all), null: false)
      add(:user_id, references(:users, on_delete: :delete_all), null: false)
      timestamps()
    end

    create(index(:members, [:organization_id]))
    create(index(:members, [:user_id]))
    create(unique_index(:members, [:organization_id, :user_id]))
  end
end
