defmodule Docs.DocsChannel do
  use Docs.Web, :channel

  alias Docs.{DocumentSaveServer, ViewingUsersList}

  def join("docs:channel", %{"id" => id} = message, socket) do
    send(self, {:after_join, message})

    DocumentSaveServer.create(id)
    ViewingUsersList.create(id)

    {:ok, socket}
  end

  def handle_info({:after_join, message}, socket) do
    %{"user_id" => user_id, "user_name" => user_name, "id" => document_id} = message

    user = %{id: user_id, name: user_name}
    users = ViewingUsersList.add_user(document_id, user)
    update_viewing_users(socket, document_id, users)

    socket =
      socket
      |> assign(:user_id, user_id)
      |> assign(:document_id, document_id)

    {:noreply, socket}
  end

  def handle_in("new:content", msg, socket) do
    %{
      "id" => id,
      "content" => content,
      "position" => position,
      "user_name" => user_name
    } = msg

    broadcast!(socket, "new:content", %{
      document_id: id,
      content: content,
      position: position,
      user_name: user_name})

    DocumentSaveServer.update(id, content, socket)

    content
    |> expressions
    |> Enum.map(fn(expr) ->
        value = Expr.eval!(expr)
        broadcast!(socket, "replace:expression", %{expression: expr, value: value})
    end)

    {:noreply, socket}
  end

  def terminate(reason, socket) do
    case socket.assigns do
      %{user_id: user_id, document_id: document_id} ->
        users = ViewingUsersList.remove_user(document_id, user_id)
        update_viewing_users(socket, document_id, users)
      _ -> :ok
    end
  end

  defp update_viewing_users(socket, document_id, users) do
    broadcast!(socket, "update:users", %{
      document_id: document_id,
      users: users
    })
  end

  defp expressions(content) do
    Regex.scan(~r/{{[^}]*}}/, content)
    |> Enum.map(&List.first/1)
    |> Enum.map(fn call ->
      Regex.named_captures(~r/{{(?<expression>[^}]*)}}/, call)
    end)
    |> Enum.map(fn x -> x["expression"] end)
    |> Enum.map(&String.strip/1)
    |> Enum.uniq
  end
end
