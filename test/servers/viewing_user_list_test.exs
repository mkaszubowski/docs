defmodule Docs.ViewingUsersListTest do
  use Docs.ChannelCase, async: false

  alias Docs.ViewingUsersList

  @document_id 1

  setup do
    ViewingUsersList.create(@document_id)
    :ok
  end

  describe "adding user" do
    test "adds user to state and returns the list of users" do
      user = %{id: 123, name: "Adam"}

      assert ViewingUsersList.add_user(@document_id, user) == [user]
    end
  end

  describe "removing user" do
    test "removes user from the state and returns the list of users" do
      user = %{id: 123, name: "Adam"}
      [user] = ViewingUsersList.add_user(@document_id, user)

      assert ViewingUsersList.remove_user(@document_id, user.id) == []
    end
  end

  describe "users list" do
    test "returns the list of users" do
      user = %{id: 123, name: "Adam"}
      [user] = ViewingUsersList.add_user(@document_id, user)

      assert ViewingUsersList.get_users(@document_id) == [user]
    end
  end
end
