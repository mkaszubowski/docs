defmodule Docs.Repo.Migrations.AddOwnerIdToDocuments do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :owner_id, references(:users, on_delete: :nothing)
    end

    create index(:documents, [:owner_id])
  end
end
