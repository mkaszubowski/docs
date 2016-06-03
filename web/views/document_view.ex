defmodule Docs.DocumentView do
  use Docs.Web, :view

  def invitations_link(conn, document) do
    if document.owner_id == conn.assigns.current_user.id do
      link("View invitations",
        to: document_invitation_path(conn, :index, document.id))
    end
  end
end
