defmodule Directory.DataStore do
  @moduledoc """
  Documentation for Directory Data Store.
  """
  use Agent
  require Logger

  @doc """
  Starts a single new bucket.
  """
  def start_link(_opts) do
    Logger.debug fn -> "DataStore starting...Directory" end
    users = Directory.seed_users
    Agent.start_link(fn -> users end, name: __MODULE__)
  end

  @doc """
  Gets a value from the `bucket` by `key`.
  """
  def get(key) do
    Agent.get(__MODULE__, &Map.get(&1, key))
  end

  @doc """
  Puts the `value` for the given `key` in the `bucket`.
  """
  def put(key, value) do
    IO.puts "Directory DataStore: put #{key}, #{inspect value}"
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

end
