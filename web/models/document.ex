defmodule Docs.Document do
  use Docs.Web, :model

  schema "documents" do
    field :name, :string
    field :content, :string

    timestamps
  end

  @required_fields ~w(name)
  @optional_fields ~w(content)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
