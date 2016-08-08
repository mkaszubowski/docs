defmodule Docs.DocsChannel do
  use Docs.Web, :channel

  alias Docs.{DocumentSaveServer, ViewingUsersList}

  def join("docs:" <> id, message, socket) do
    send(self, {:after_join, message})

    DocumentSaveServer.create(id)
    ViewingUsersList.create(id)

    {:ok, assign(socket, :document_id, id)}
  end

  def handle_info({:after_join, message}, socket) do
    %{"user_id" => user_id, "user_name" => user_name} = message
    document_id = socket.assigns.document_id

    user = %{id: user_id, name: user_name}
    ViewingUsersList.add_user(document_id, user)

    socket =
      socket
      |> assign(:user_id, user_id)

    {:noreply, socket}
  end

  def handle_in("new:content", msg, socket) do
    %{
      "content" => content,
      "position" => position,
      "user_name" => user_name
    } = msg

    broadcast!(socket, "new:content", %{
      content: content,
      position: position,
      user_name: user_name})

    DocumentSaveServer.update(socket.assigns.document_id, content, socket)

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
        ViewingUsersList.remove_user(document_id, user_id)
      _ -> :ok
    end
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
