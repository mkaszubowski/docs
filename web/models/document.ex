defmodule Docs.Document do
  use Docs.Web, :model

  alias Docs.Invitation

  schema "documents" do
    field :name, :string
    field :content, :string

    timestamps

    has_many :invitations, Invitation
    has_many :users, through: [:invitations, :user]
  end

  @required_fields ~w(name)
  @optional_fields ~w(content)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:name, &String.lstrip/1)
    |> validate_length(:name, min: 1, message: "Can't be blank")
  end
end
