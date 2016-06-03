defmodule Docs.Repo.Migrations.AddTokenToInvitations do
  use Ecto.Migration

  def change do
    alter table(:invitations) do
      add :token, :string
    end
  end
end
