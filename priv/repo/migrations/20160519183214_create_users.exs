defmodule Docs.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :name, :string
      add :crypted_password, :string

      timestamps
    end
  end
end
