defmodule Docs.DocumentTest do
  use Docs.ModelCase

  alias Docs.{Repo, Document}

  test "is invalid without the name" do
    changeset = Document.changeset(%Document{}, %{name: ""})

    refute changeset.valid?
  end

  test "name can't be blank" do
    changeset = Document.changeset(%Document{}, %{name: "    "})

    refute changeset.valid?
  end

  test "is valid without the content" do
    changeset = Document.changeset(%Document{}, %{name: "document", content: ""})

    assert changeset.valid?
  end
end
