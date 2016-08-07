defmodule Docs.DocumentRepoTest do
  use Docs.ModelCase

  alias Docs.{Document, Repo}

  setup do
    user = insert_user
    attrs = %{
      owner_id: user.id,
      name: "Document"
    }

    {:ok, user: user, attrs: attrs}
  end

  test "creates invitation for the owned when created", meta do
    {:ok, %{id: document_id}} =
      %Document{}
      |> Document.changeset(meta.attrs)
      |> Repo.insert()

    %Document{invitations: [invitation]} =
      Document
      |> Repo.get(document_id)
      |> Repo.preload(:invitations)

    assert invitation.document_id == document_id
    assert invitation.user_id == meta.user.id
  end

  test "does not create duplicated invitation when updating", meta do
    {:ok, document} =
      %Document{}
      |> Document.changeset(meta.attrs)
      |> Repo.insert()

    document
    |> Document.changeset(%{name: "Updated"})
    |> Repo.update()


    %Document{name: "Updated", invitations: [invitation]} =
      Document
      |> Repo.get(document.id)
      |> Repo.preload(:invitations)

    assert invitation.document_id == document.id
    assert invitation.user_id == meta.user.id

  end
end
