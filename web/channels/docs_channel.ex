defmodule Docs.DocsChannel do
  use Docs.Web, :channel

  def join("docs:test", message, socket) do
    send(self, {:after_join, message})
    {:ok, socket}
  end

  def handle_in("new:content", message, socket) do
    broadcast! socket, "new:content", %{content: message["content"]}

    {:noreply, socket}
  end
end
