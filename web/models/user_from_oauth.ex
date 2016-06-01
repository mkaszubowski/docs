defmodule Docs.UserFromOAuth do
  alias Ueberauth.Auth
  alias Docs.{Repo, User}

  def find_or_create(%Auth{} = auth) do
    case Repo.get_by(User, %{email: auth.info.email}) do
      %User{} = user -> {:ok, user}
      nil -> create_user(auth)
    end
  end

  defp create_user(auth) do
    changeset = User.changeset(%User{}, %{
      email: auth.info.email,
      name: "#{auth.info.first_name} #{auth.info.last_name}",
    })

    if changeset.valid? do
      Repo.insert(changeset)
    else
      {:error, "Could not create the user"}
    end
  end
end
