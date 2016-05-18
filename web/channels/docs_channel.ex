defmodule Docs.DocsChannel do
  use Docs.Web, :channel

  alias Docs.DocumentSaveServer

  def join("docs:test", %{"id" => id} = message, socket) do
    send(self, {:after_join, message})
    {:ok, _pid} = DocumentSaveServer.start_link(id)

    {:ok, socket}
  end

  def handle_in("new:content", %{"id" => id, "content" => content}, socket) do
    broadcast! socket, "new:content", %{content: content}

    DocumentSaveServer.update(id, content)

    {:noreply, socket}
  end
end
