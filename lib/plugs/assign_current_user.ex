defmodule Docs.Plugs.AssignCurrentUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Docs.{Repo, User}

  def init(default), do: default

  def call(conn, _default) do
    user_id = get_session(conn, :user_id)
    if user_id do
      user = Repo.get(User, user_id)
      assign(conn, :current_user, user)
    else
      conn
    end
  end
end
