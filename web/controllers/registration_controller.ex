defmodule Docs.RegistrationController do
  use Docs.Web, :controller

  alias Docs.{Repo, User}

  def new(conn, _params) do
    render(conn, "new.html", conn: conn)
  end

  def create(conn, %{"user" => params}) do
    changeset = User.changeset(%User{}, params)
    IO.puts(inspect changeset)

    case Repo.insert(changeset) do
      {:ok, user} ->
        redirect(conn, to: document_path(conn, :index))
      {:error, reason} ->
        IO.puts(inspect reason)
        render("new.html")
    end
  end
end
