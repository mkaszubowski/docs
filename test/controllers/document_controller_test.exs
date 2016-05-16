defmodule Docs.DocumentControllerTest do
  use Docs.ConnCase

  alias Docs.{Repo, Document}

  setup do
    document = Repo.insert!(%Document{name: "document1"})

    {:ok, document: document}
  end

  test "GET /documents", %{conn: conn, document: document} do
    conn = get conn, "/documents"

    assert html_response(conn, 200) =~ "document1"
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
end
