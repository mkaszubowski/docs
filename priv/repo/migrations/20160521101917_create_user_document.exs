defmodule Docs.Repo.Migrations.CreateUserDocument do
  use Ecto.Migration

  def change do
    create table(:users_documents) do
      add :user_id, references(:users, on_delete: :nothing)
      add :document_id, references(:documents, on_delete: :nothing)
      add :type, :string

      timestamps
    end

    create index(:users_documents, [:user_id])
    create index(:users_documents, [:document_id])
    create unique_index(:users_documents, [:user_id, :document_id])
  end
end
