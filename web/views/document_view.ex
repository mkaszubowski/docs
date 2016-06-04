defmodule Docs.DocumentView do
  use Docs.Web, :view

  def document_owner?(conn, document) do
    document.owner_id == conn.assigns.current_user.id
  end
end
