defmodule Docs.DocumentTest do
  use Docs.ModelCase, async: true

  alias Docs.Document

  setup do
    user = insert_user

    basic_attrs = %{"owner_id" => user.id}

    {:ok, basic_attrs: basic_attrs}
  end

  test "is invalid without the name", %{basic_attrs: basic_attrs} do
    attrs = Dict.merge(basic_attrs, %{"name" => ""})
    changeset = Document.changeset(%Document{}, attrs)

    refute changeset.valid?
  end

  test "name can't be blank", %{basic_attrs: basic_attrs} do
    attrs = Dict.merge(basic_attrs, %{"name" => "    "})
    changeset = Document.changeset(%Document{}, attrs)

    refute changeset.valid?
  end

  test "is valid without the content", %{basic_attrs: basic_attrs} do
    attrs = Dict.merge(basic_attrs, %{"name" => "document", "content" => ""})
    changeset = Document.changeset(%Document{}, attrs)

    assert changeset.valid?
  end

  test "is invalid without the owner id" do
    changeset = Document.changeset(%Document{}, %{name: "Document"})

    refute changeset.valid?
    assert changeset.errors[:owner_id] == "can't be blank"
  end
end
