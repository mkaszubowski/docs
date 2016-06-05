defmodule Docs.ViewingUsersList do
  use GenServer

  ## Client API

  def create(document_id) do
    case GenServer.whereis(server_name(document_id)) do
      nil ->
        Supervisor.start_child(Docs.ViewingUsersListSupervisor, [document_id])
      _list ->
        {:error, :users_list_already_exists}
    end
  end

  def start_link(document_id) do
    GenServer.start_link(
      __MODULE__,
      :ok,
      name: server_name(document_id)
    )
  end

  def add_user(document_id, user) do
    document_id
    |> server_name
    |> GenServer.call({:add_user, user})
  end

  def remove_user(document_id, user_id) do
    document_id
    |> server_name
    |> GenServer.call({:remove_user, user_id})
  end

  ## Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_call({:add_user, user}, _from, users) do
    users =
      case users do
        %{} -> [user]
        _ -> [user | users]
      end
      |> Enum.uniq

    {:reply, users, users}
  end

  def handle_call({:remove_user, user_id}, _from, users) do
    users = Enum.reject(users, fn(u) -> u.id == user_id end)

    {:reply, users, users}
  end

  def handle_info(_, state) do
    {:ok, state}
  end

  defp server_name(document_id) do
    String.to_atom("viewing-users-#{document_id}")
  end
end
