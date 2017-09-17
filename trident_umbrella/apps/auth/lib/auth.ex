defmodule Auth do
  @moduledoc """
  Documentation for Auth context.
  """

  alias Auth.Session
  alias Auth.DataStore

  @doc """
  Adds user to Data Store.
  """
  def add_session(email) do
    DataStore.put(email, uuid(email))
  end

  defp uuid(email) do
    UUID.uuid5(:url, email)
  end

end
