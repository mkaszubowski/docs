defmodule Docs.DocumentController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document, Plugs}

  plug Plugs.CheckDocumentPermissions, "id" when action in [:show]
  plug Plugs.RequireDocumentPermission, "view" when action in [:show]
  plug Plugs.CheckDocumentOwner when action in [:delete]

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns[:current_user]]
    apply(__MODULE__, action_name(conn), args)
  end

  def show(conn, %{"id" => id}, current_user) do
    id = String.to_integer(id)

    case Repo.get(Document, id) do
      %Document{} = document ->
        render(conn, "show.html",
          document: document,
          conn: conn,
          permission: conn.assigns.document_permission,
          current_user: current_user)
      _ ->
        redirect(conn, to: document_path(conn, :index))
    end
  end

  def index(conn, params, current_user) do
    documents =
      Document
      |> Document.search(params["search"]["term"])
      |> Document.for_user(current_user.id)
      |> Repo.all

    render(conn, "index.html",
      documents: documents,
      changeset: Document.changeset(%Document{}))
  end

  def create(conn, %{"document" => params}, current_user) do
    changeset = Document.changeset(%Document{},
      Map.merge(params, %{"owner_id" => current_user.id}))

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, document} ->
          conn
          |> put_flash(:info, "Document created")
          |> redirect(to: document_path(conn, :show, document))
        {:error, _} ->
          conn
          |> put_flash(:info, "Could not create the document")
          |> redirect(to: document_path(conn, :index))
      end
    end
    redirect(conn, to: document_path(conn, :index))
  end

  def delete(conn, %{"id" => id}, _current_user) do
    document = Repo.get(Document, String.to_integer(id))

    case Repo.delete(document) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Document deleted")
        |> redirect(to: document_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "Could not delete the document")
        |> redirect(to: document_path(conn, :index))
    end
  end
end
