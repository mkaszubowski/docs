defmodule Docs.Repo.Migrations.AddNameToDocuments do
  use Ecto.Migration

  def change do
    alter table(:documents) do
      add :name, :string, null: false
    end
  end
end
