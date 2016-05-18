defmodule Docs.DocumentController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document}

  def show(conn, %{"id" => id}) do
    id = String.to_integer(id)

    case Repo.get(Document, id) do
      %Document{} = document ->
        render(conn, "show.html", document: document)
      _ ->
        redirect(conn, to: document_path(conn, :index))
    end
  end

  def index(conn, _params) do
    documents = Repo.all(Document)
    changeset = Document.changeset(%Document{})

    render(conn, "index.html", documents: documents, changeset: changeset)
  end

  def create(conn, %{"document" => params}) do
    changeset = Document.changeset(%Document{}, params)

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, document} ->
          redirect(conn, to: document_path(conn, :show, document))
      end
    end
    redirect(conn, to: document_path(conn, :index))
  end
end
