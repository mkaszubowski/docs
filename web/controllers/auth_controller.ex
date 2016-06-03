defmodule Docs.AuthController do
  use Docs.Web, :controller

  plug Ueberauth
  alias Ueberauth.Strategy.Helpers
  alias Docs.UserFromOAuth

  def login(conn, _params) do
    render(conn, "login.html", conn: conn)
  end

  def delete(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_failure: _reason}} = conn, _params) do
    conn
    |> put_flash(:error, "Could not authenticate")
    |> redirect(to: "/")
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UserFromOAuth.find_or_create(auth) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome, #{user.name}")
        |> redirect(to: document_path(conn, :index))
      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: "/")

    end
  end
end
