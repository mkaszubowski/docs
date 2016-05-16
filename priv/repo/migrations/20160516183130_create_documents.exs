defmodule Docs.Repo.Migrations.CreateDocuments do
  use Ecto.Migration

  def change do
    create table(:documents) do
      add :content, :text

      timestamps
    end
  end
end
