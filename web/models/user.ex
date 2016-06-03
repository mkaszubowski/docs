defmodule Docs.User do
  use Docs.Web, :model

  alias Comeonin.Bcrypt
  alias Docs.Invitation

  schema "users" do
    field :email, :string
    field :name, :string

    timestamps

    has_many :invitations, Invitation
    has_many :documents, through: [:invitations, :document]
  end

  @required_fields ~w(email)
  @optional_fields ~w(name)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, message: "Can't be blank")
    |> unique_constraint(:email, message: "Email already taken")
  end
end
