defmodule Docs.Plugs.CheckDocumentPermissions do
  import Plug.Conn
  import Phoenix.Controller

  alias Docs.{Repo, Invitation}

  def init(default), do: default

  def call(conn, []), do: check(conn, conn.params["document_id"])
  def call(conn, id_param_key), do: check(conn, conn.params[id_param_key])

  defp check(conn, document_id) do
    current_user_id = conn.assigns.current_user.id

    case Repo.get_by(Invitation,
      %{document_id: document_id, user_id: current_user_id}) do
      nil ->
        conn
        |> put_flash(:error, "You don't have permissions to do that")
        |> redirect(to: "/")
      %Invitation{type: type} = invitation->
        assign(conn, :document_permission, type)
    end
  end
end
