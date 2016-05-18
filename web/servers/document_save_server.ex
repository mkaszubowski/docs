defmodule Docs.DocumentSaveServer do
  use GenServer
  use Docs.Web, :channel


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

  def update(document_id, content, socket) do
    document_id
    |> server_name
    |> GenServer.cast({:update, content, socket})
  end

  ## Server Callbacks

  def init(%{document_id: document_id}) do
    {:ok, %{document_id: document_id, timer: nil}}
  end


  def handle_cast({:update, content, socket}, %{timer: timer, document_id: document_id}) do
    if timer, do: :erlang.cancel_timer(timer)

    timer = Process.send_after(self(), :save, 2500)

    {:noreply, %{timer: timer, document_id: document_id, content: content, socket: socket}}
  end

  def handle_info(:save, %{document_id: document_id, content: content, socket: socket} = state) do
    IO.puts("save")
    document = Repo.get(Document, String.to_integer(document_id))
    changeset = Document.changeset(document, %{content: content})

    case Repo.update(changeset) do
      {:ok, doc} ->
        broadcast! socket, "document:saved", %{}
      {:error, reason} ->
        broadcast! socket, "document:save-error", %{reason: reason}
        IO.puts(inspect reason)
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
