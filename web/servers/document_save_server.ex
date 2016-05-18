defmodule Docs.DocumentSaveServer do
  use GenServer

  alias Docs.{Repo, Document}

  ## Client API

  def start_link(document_id) do
    name = server_name(document_id)

    GenServer.start_link(
      __MODULE__,
      %{document_id: document_id},
      name: name
    )
  end

  def update(document_id, content) do
    document_id
    |> server_name
    |> GenServer.cast({:update, content})
  end

  ## Server Callbacks

  def init(%{document_id: document_id}) do
    {:ok, %{document_id: document_id, timer: nil}}
  end


  def handle_cast({:update, content}, %{timer: timer, document_id: document_id}) do
    if timer, do: :erlang.cancel_timer(timer)

    timer = Process.send_after(self(), :save, 5000)

    {:noreply, %{timer: timer, document_id: document_id, content: content}}
  end

  def handle_info(:save, %{document_id: document_id, content: content} = state) do
    document = Repo.get(Document, String.to_integer(document_id))
    changeset = Document.changeset(document, %{content: content})

    case Repo.update(changeset) do
      {:ok, doc} -> IO.puts("ok")
      {:error, reason} -> IO.puts(inspect reason)
    end

    {:noreply, state}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp server_name(document_id) do
    String.to_atom("document-#{document_id}")
  end
end
