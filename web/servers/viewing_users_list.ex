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
      %{document_id: document_id},
      name: server_name(document_id)
    )
  end

  def add_user(document_id, user) do
    document_id
    |> server_name
    |> GenServer.cast({:add_user, user})
  end

  def remove_user(document_id, user_id) do
    document_id
    |> server_name
    |> GenServer.cast({:remove_user, user_id})
  end

  def get_users(document_id) do
    document_id
    |> server_name
    |> GenServer.call(:get_users)
  end

  ## Server Callbacks

  def init(%{document_id: document_id}) do
    :timer.send_interval(1_000, :after_init)

    {:ok, %{users: [], nodes: [], shared_users: %{}, document_id: document_id}}
  end

  def handle_call(:get_users, _from, state) do
    users = get_users_from_state(state)
    {:reply, users, state}
  end

  def handle_cast({:add_user, user}, %{users: users} = state) do
    users =
      case users do
        %{} -> [user]
        _ -> [user | users]
      end
      |> Enum.uniq

    broadcast_users(state)

    new_state = %{state | users: users}

    init_nodes_sync(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:remove_user, user_id}, %{users: users} = state) do
    users = Enum.reject(users, fn(user) -> user.id == user_id end)

    broadcast_users(state)

    new_state = %{state | users: users}

    init_nodes_sync(new_state)
    {:noreply, new_state}
  end

  def handle_cast({:sync_users, pid}, state) do
    send(pid, {:user_sync, Node.self(), state.users})

    {:noreply, state}
  end

  def handle_info({:user_sync, node, node_users}, %{users: users} = state) do
    new_shared_users = Map.merge(state.shared_users, %{node => node_users})

    broadcast_users(state)

    new_state = %{state | shared_users: new_shared_users}
    {:noreply, new_state}
  end

  def handle_info(:after_init,
      %{users: users, nodes: nodes, document_id: document_id} = state) do
    case Node.list -- nodes do
      [] -> {:noreply, state}
      new_nodes ->
        for node <- new_nodes, do: Node.monitor(node, true)

        nodes = nodes ++ new_nodes |> Enum.uniq
        new_state = %{state | nodes: nodes}

        init_nodes_sync(new_state)

        {:noreply, new_state}
    end
  end

  def handle_info({:nodedown, node},
      %{nodes: nodes, shared_users: shared_users} = state) do
    nodes = List.delete(nodes, node)
    shared_users = Map.delete(shared_users, node)

    new_state = %{state | nodes: nodes, shared_users: shared_users}
    init_nodes_sync(new_state)
    broadcast_users(new_state)

    {:noreply, new_state}
  end

  def handle_info(_, state) do
    {:noreply, state}
  end

  defp broadcast_users(%{document_id: document_id} = state) do
    users = get_users_from_state(state)

    Docs.Endpoint.broadcast(
      "docs:#{document_id}",
      "update:users",
      %{users: users})
  end

  defp init_nodes_sync(%{nodes: nodes, document_id: document_id}) do
    name = server_name(document_id)

    for node <- nodes do
      parent = self()

      Task.async(fn ->
        case GenServer.whereis(name) do
          nil -> []
          _node ->
            GenServer.cast({name, node}, {:sync_users, parent})
        end
      end)
    end
  end

  defp get_users_from_state(state) do
    shared_users = state.shared_users |> Map.values |> List.flatten

    Enum.uniq(shared_users ++ state.users)
  end

  defp server_name(document_id) do
    String.to_atom("viewing-users-#{document_id}")
  end
end
