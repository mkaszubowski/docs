defmodule Docs.Repo.Migrations.CreateUserDocument do
  use Ecto.Migration

  def change do
      add :user_id, references(:users, on_delete: :nothing)
      add :document_id, references(:documents, on_delete: :nothing)
