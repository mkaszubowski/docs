defmodule Docs.UserTest do
  use Docs.ModelCase

  alias Docs.{Repo, User}

  @valid_attrs %{email: "foo@bar.com", password: "foobar123", name: "Foobar"}
  @invalid_attrs %{email: "", password: ""}

  test "is valid without the name" do
    changeset = User.changeset(%User{}, @valid_attrs)

    assert changeset.valid?
  end

  test "is invalid without the email" do
    changeset = User.changeset(%User{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "is does not store password" do
    changeset = User.changeset(%User{}, @valid_attrs);
    {:ok, user} = Repo.insert(changeset)

    refute user.crypted_password == @valid_attrs["password"]
  end

  test "email has to be unique" do
    changeset = User.changeset(%User{}, %{email: "foo@bar.com", password: "foobar"})
    Repo.insert!(changeset)

    {status, _} = Repo.insert(changeset)

    assert status == :error
  end
end
