defmodule Docs.Plugs.Authenticate do
  import Plug.Conn
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _default) do
    unless conn.assigns[:current_user] do
      conn
        |> put_flash(:error, 'You need to be signed in to view this page.')
        |> redirect(to: "/")
    end
  end
end
