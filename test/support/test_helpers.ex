defmodule Docs.TestHelpers do
  alias Docs.{User, Repo}

  def insert_user(attrs \\ %{}) do
    changes = Dict.merge(%{
      email: random_email(),
      name: "User"
    }, attrs)

    %User{}
    |> User.changeset(changes)
    |> Repo.insert!()
  end

  defp random_email do
    "user-#{Base.encode16(:crypto.rand_bytes(8))}@gmail.com"
  end
end
