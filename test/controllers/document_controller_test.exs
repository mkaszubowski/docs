defmodule Docs.DocumentControllerTest do
  use Docs.ConnCase

  alias Docs.{Repo, Document}

  setup do
    user = insert_user
    document = Repo.insert!(%Document{name: "document1", owner_id: user.id})

    conn = conn() |> assign(:current_user, user)

    {:ok, document: document, conn: conn}
  end

  test "GET /documents", %{document: document, conn: conn} do
    conn = get conn, "/documents"

    assert html_response(conn, 200) =~ document.name
  end

  test "GET /documents/:id", %{document: document, conn: conn} do
    conn = get conn, "/documents/#{document.id}"

    assert html_response(conn, 200) =~ "document1"
    assert html_response(conn, 200) =~ "<textarea"
  end

  test "POST /documents", %{conn: conn} do
    params = %{name: "document"}
    conn = post conn, "/documents", document: params

    document =
      Document
      |> Repo.all
      |> Enum.reverse
      |> Enum.at(0)

    assert document.name == "document"
    assert redirected_to(conn) == document_path(conn, :index)
  end

  test "DELETE /documents/:id", %{document: document, conn: conn} do
    delete conn, "/documents/#{document.id}"

    assert Repo.get(Document, document.id) == nil
  end
end
