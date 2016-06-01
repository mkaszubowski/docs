defmodule Docs.Invitation do
  use Docs.Web, :model

  schema "invitations" do
    belongs_to :user, Docs.User
    belongs_to :document, Docs.Document
    field :type, :string

    timestamps
  end

  @required_fields ~w(user_id document_id type)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id_document_id,
        message: "Permission already exists")
  end
end
