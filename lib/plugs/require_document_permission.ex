defmodule Docs.Plugs.RequireDocumentPermission do
  import Plug.Conn
  import Phoenix.Controller

  alias Docs.{Repo, Invitation}

  def init(default), do: default

  def call(conn, "view") do
    case conn.assigns.document_permission do
      nil -> not_authorized(conn)
      _   -> conn
    end
  end

  def call(conn, "edit") do
    case conn.assigns.document_permission do
      "edit" -> conn
      _      -> not_authorized(conn)
    end
  end

  defp not_authorized(conn) do
    conn
    |> put_flash(:error, "You don't have permissions to do that")
    |> redirect(to: "/")
  end

end
