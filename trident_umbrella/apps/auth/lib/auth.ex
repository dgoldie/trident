defmodule Auth do
  @moduledoc """
  Documentation for Auth context.
  """

  alias Auth.Session
  alias Auth.DataStore

  @doc """
  Gets session from Data Store.
  """
  def get_session(uuid) do
    result = DataStore.get(uuid)
    IO.puts "****** get_session: for #{uuid}, result = #{result}"
    result
  end

  @doc """
  Adds session to Data Store.
  """
  def add_session(email) do
    token = uuid(email)
    IO.puts "add_session for email: #{email}, token = #{token}"
    DataStore.put(token, email)

    token
  end

  defp uuid(email) do
    UUID.uuid5(:url, email)
  end

  @doc """
  Delete session from Data Store.
  """
  def delete_session(uuid) do
    DataStore.delete(uuid)
  end

end
