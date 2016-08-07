defmodule Docs.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
        |> put_flash(:error, 'You need to be signed in to view this page.')
        |> halt()
        |> redirect(to: "/auth/login")
    end
  end
end
