defmodule Docs.DocumentController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document}

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns[:current_user]]
    apply(__MODULE__, action_name(conn), args)
  end

  def show(conn, %{"id" => id}, current_user) do
    id = String.to_integer(id)

    case Repo.get(Document, id) do
      %Document{} = document ->
        check_document_permissions(conn, document)

        render(conn, "show.html",
          document: document, conn: conn, current_user: current_user)
      _ ->
        redirect(conn, to: document_path(conn, :index))
    end
  end

  def index(conn, params, _current_user) do
    documents =
      Document
      |> Document.search(params["search"])
      |> Document.for_user(conn.assigns.current_user.id)
      |> Repo.all

    changeset = Document.changeset(%Document{})

    render(conn, "index.html", documents: documents, changeset: changeset)
  end

  def create(conn, %{"document" => params}, current_user) do
    changeset = Document.changeset(%Document{}, params)

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

  defp check_document_permissions(conn, document) do
    user_documents_ids =
      Document
      |> Document.for_user(conn.assigns.current_user.id)
      |> Repo.all
      |> Enum.map(&(&1.id))

    unless Enum.member?(user_documents_ids, document.id) do
      conn
      |> put_flash(:error, "You don't have permissions to view this document")
      |> redirect(to: "/")
    end
  end
end
