defmodule Docs.InvitationTest do
  use Docs.ModelCase

  alias Docs.{Invitation, Repo, User, Document}

  @valid_attrs %{"user_id" => 1, "document_id" => 1, "type" => "edit"}
  @invalid_attrs %{}

  setup do
    user     = insert_user
    document = Repo.insert!(%Document{content: "test", name: "doc"})

    {:ok, %{user: user, document: document}}
  end

  test "changeset with valid attributes" do
    changeset = Invitation.changeset(%Invitation{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Invitation.changeset(%Invitation{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "user_id and document_id combination has to be unique",
    %{user: user, document: document} do

    changeset = Invitation.changeset(%Invitation{}, %{
        user_id: user.id,
        document_id: document.id,
        type: "edit"
    })

    {:ok, _user_doc} = Repo.insert(changeset)
    {status, reason} = Repo.insert(changeset)

    assert status == :error
    assert reason.errors == [user_id_document_id: "Invitation already exists"]
  end
end
