defmodule Docs.Document do
  use Docs.Web, :model

  alias Docs.Invitation

  schema "documents" do
    field :name, :string
    field :content, :string

    timestamps

    belongs_to :owner, User
    has_many :invitations, Invitation, on_delete: :delete_all
    has_many :users, through: [:invitations, :user]
  end

  @required_fields ~w(name)
  @optional_fields ~w(content owner_id)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> update_change(:name, &String.lstrip/1)
    |> validate_length(:name, min: 1, message: "Can't be blank")
    |> create_owner_invitation(params)
  end

  defp create_owner_invitation(model, params) do
    case model.model.id do
      nil ->
        case params do
          %{"owner_id" => owner_id} ->
            put_assoc(
              model,
              :invitations,
              [%Invitation{user_id: owner_id, type: "edit"}]
            )
          :empty -> model
        end
      _ -> model
    end
  end

  def for_user(query, user_id) do
    from(d in query,
      left_join: user in assoc(d, :users),
      where: user.id == ^user_id)
  end

  def search(query, expression) do
    case expression do
      x when x == "" or is_nil(x) -> query
      _ ->
        from document in query,
          where: fragment("? % ?", document.name, ^expression)
    end
  end
end
