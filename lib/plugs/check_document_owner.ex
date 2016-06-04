defmodule Docs.Plugs.CheckDocumentOwner do
  import Plug.Conn
  import Phoenix.Controller

  alias Docs.{Repo, Document}

  def init(default), do: default

  def call(conn, []),
    do: check(conn, conn.params["document_id"])
  def call(conn, id_param_key),
    do: check(conn, conn.params[id_param_key])

  defp check(conn, document_id) do
    current_user_id = conn.assigns.current_user.id

    case Repo.get(Document, document_id) do
      %Document{owner_id: ^current_user_id} = document ->
        assign(conn, :document, document)
      _ ->
        conn
        |> put_flash(:error, "You don't have permissions to do that")
        |> redirect(to: "/")
    end
  end
end
