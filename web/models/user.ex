defmodule Docs.User do
  use Docs.Web, :model

  alias Comeonin.Bcrypt
  alias Docs.UserDocument

  schema "users" do
    field :email, :string
    field :name, :string
    field :password, :string, virtual: true
    field :crypted_password, :string

    timestamps

    has_many :users_documents, UserDocument
    has_many :documents, through: [:users_documents, :document]
  end

  @required_fields ~w(email password)
  @optional_fields ~w(name)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> put_change(:crypted_password, hashed_password(params["password"]))
    |> update_change(:email, &String.downcase/1)
    |> validate_length(:email, min: 1, message: "Can't be blank")
    |> unique_constraint(:email, message: "Email already taken")
  end

  defp hashed_password(password) do
    Bcrypt.hashpwsalt(password)
  end
end
