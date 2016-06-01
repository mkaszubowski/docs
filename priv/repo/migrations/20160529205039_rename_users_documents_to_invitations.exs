defmodule Docs.Repo.Migrations.RenameUsersDocumentsToInvitations do
  use Ecto.Migration

  def change do
    rename table(:users_documents), to: table(:invitations)
  end
end
