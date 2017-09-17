defmodule Auth.DataStore do
  @moduledoc """
  Documentation for Auth Data Store.
  """
  use Agent
  require Logger

  @doc """
  Starts a single new bucket.
  """
  def start_link(_opts) do
    Logger.debug fn -> "DataStore starting...Auth" end
    Agent.start_link(fn -> %{} end, name: __MODULE__)
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
    Agent.update(__MODULE__, &Map.put(&1, key, value))
  end

end
