defmodule Docs.InvitationController do
  use Docs.Web, :controller

  alias Docs.{Repo, Document, Invitation, TokenGenerator}

  def index(conn, %{"document_id" => document_id}) do
    document = Repo.get(Document, document_id)
    invitations =
      Invitation
      |> Invitation.for_document(document_id)
      |> Invitation.accepted
      |> Invitation.with_user
      |> Repo.all

    changeset = Invitation.changeset(%Invitation{})

    render(conn, "index.html",
      document: document,
      invitations: invitations,
      changeset: changeset,
      conn: conn)
  end

  def accept(conn, %{"document_id" => document_id, "token" => token}) do
    case Repo.get_by(Invitation, %{token: token}) do
      %Invitation{} = invitation ->
        changeset = Invitation.changeset(invitation, %{
          user_id: conn.assigns.current_user.id,
          token: ""})

        case Repo.update(changeset) do
          {:ok, _} ->
            conn
            |> put_flash(:info, "Invitation accepted")
            |> redirect(to: document_path(conn, :show, document_id))
          {:error, _} ->
            conn
            |> put_flash(:error, "Error while accepting invitation")
            |> redirect(to: "/")
        end
      nil ->
        conn
        |> put_flash(:error, "Invitation not found")
        |> redirect(to: "/")
    end
  end

  def create(conn, %{"document_id" => document_id, "invitation" => invitation}) do
    changeset = Invitation.changeset(%Invitation{}, %{
      document_id: document_id,
      type: invitation["type"],
      token: TokenGenerator.get_token
    })

    if changeset.valid? do
      case Repo.insert(changeset) do
        {:ok, invitation} ->
          conn
          |> put_flash(:info, "User invited to #{invitation["type"]} the document")
          |> redirect(to: document_path(conn, document_id))
        {:error, _reason} ->
          conn
          |> put_flash(:error, "Could not invite this user")
          |> redirect(to: document_path(conn, document_id))
      end
    end
  end
end
