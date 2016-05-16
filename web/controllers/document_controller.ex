defmodule Docs.DocumentController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document}

  def index(conn, _params) do
    documents = Repo.all(Document)

    render conn, "index.html", documents: documents
  end
end
