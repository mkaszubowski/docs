defmodule Docs.Invitation do
  use Docs.Web, :model

  alias Docs.{User, Document, Invitation}

  schema "invitations" do
    field :type, :string
    field :token, :string

    belongs_to :user, User
    belongs_to :document, Document

    timestamps
  end

  @required_fields ~w(document_id type)
  @optional_fields ~w(token user_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id_document_id,
        message: "Invitation already exists")
  end

  def for_document(query, document_id) do
    from(i in query, where: i.document_id == ^document_id)
  end

  def accepted(query) do
    from(i in query, where: is_nil(i.user_id) == false)
  end

  def with_user(query) do
    from(i in query, preload: [:user])
  end
end
