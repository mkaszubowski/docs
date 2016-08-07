defmodule Docs.UserTest do
  use Docs.ModelCase

  alias Docs.{Repo, User, Document, Invitation}

  @valid_attrs %{"email" => "foo@bar.com", "password" => "foobar123", "name" => "Foobar"}
  @invalid_attrs %{"email" => "", "password" => ""}

  test "is valid without the name" do
    changeset = User.changeset(%User{}, @valid_attrs)

    assert changeset.valid?
  end

  test "is invalid without the email" do
    changeset = User.changeset(%User{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "email has to be unique" do
    changeset = User.changeset(
      %User{},
      %{"email" => "foo@bar.com", "password" => "foobar"}
    )

    Repo.insert!(changeset)

    {status, _} = Repo.insert(changeset)

    assert status == :error
  end

  test "has many documents" do
    user     = insert_user()
    doc      = Repo.insert!(%Document{name: "doc", content: "test"})

    {:ok, _} = Repo.insert(%Invitation{
        user_id: user.id, document_id: doc.id, type: "edit"
      })

    assert Repo.preload(user, [:documents]).documents == [doc]
  end
end
