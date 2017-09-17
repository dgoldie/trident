defmodule Directory do
  @moduledoc """
  Documentation for Directory Context.
  """

  # use Agent
  alias Directory.User
  alias Directory.DataStore


  # @doc """
  # Starts a new bucket.
  # """
  # def start_link(_opts) do
  #   Agent.start_link(fn -> %{} end, name: __MODULE__)
  # end

  @doc """
  Adds user to Data Store.
  """
  def add_user(user = %User{}) do
    DataStore.put(user.email, user)
  end

  # @doc """
  # Gets a value from the `bucket` by `key`.
  # """
  # def get(key) do
  #   Agent.get(__MODULE__, &Map.get(&1, key))
  # end

  # @doc """
  # Puts the `value` for the given `key` in the `bucket`.
  # """
  # defp put(key, value) do
  #   Agent.update(__MODULE__, &Map.put(&1, key, value))
  # end

end



#  def start_link do
#     Agent.start_link(fn -> MapSet.new end, name: __MODULE__)
#   end

#   @doc "Checks if the task has already executed"
#   def executed?(task, project) do
#     item = {task, project}
#     Agent.get(__MODULE__, fn set ->
#       item in set
#     end)
#   end

#   @doc "Marks a task as executed"
#   def put_task(task, project) do
#     item = {task, project}
#     Agent.update(__MODULE__, &MapSet.put(&1, item))
#   end

#   @doc "Resets the executed tasks and returns the previous list of tasks"
#   def take_all() do
#     Agent.get_and_update(__MODULE__, fn set ->
#       {Enum.into(set, []), MapSet.new}
#     end)
#   end
# end
