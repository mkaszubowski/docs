defmodule Docs.DocumentController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document}

  def index(conn, _params) do
    documents = Repo.all(Document)

    render(conn, "index.html", documents: documents)
  end

  def create(conn, %{"document" => params}) do
    changeset = Document.changeset(%Document{}, params)

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, document} ->
          redirect(conn, to: document_path(conn, :index))
      end
    end
    redirect(conn, to: document_path(conn, :index))
  end
end
