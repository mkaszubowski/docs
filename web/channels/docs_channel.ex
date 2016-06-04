defmodule Docs.DocsChannel do
  use Docs.Web, :channel

  alias Docs.DocumentSaveServer

  def join("docs:test", %{"id" => id} = message, socket) do
    send(self, {:after_join, message})
    DocumentSaveServer.start_link(id)

    {:ok, socket}
  end

  def handle_in("new:content", msg, socket) do
    %{
      "id" => id,
      "content" => content,
      "position" => position,
      "user_name" => user_name
    } = msg

    broadcast!(socket, "new:content", %{
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
