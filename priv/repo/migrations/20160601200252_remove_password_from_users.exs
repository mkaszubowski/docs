defmodule Docs.Repo.Migrations.RemovePasswordFromUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :crypted_password
    end
  end
end
