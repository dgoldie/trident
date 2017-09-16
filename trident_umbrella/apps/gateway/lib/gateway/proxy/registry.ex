defmodule Gateway.Proxy.Registry do
  @moduledoc """
    not needed
  """

  use GenServer

  ## Client API

  @doc """
  Starts the registry.
  """

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @doc"""
  Create a request proxy.
  """

  def create(server, proxy) do
    GenServer.cast(server, {:create, proxy})
  end

  ### Server Callbacks

  def init(:ok) do
    {:ok, %{}}
  end

  # def handle_call({:create, proxy}, proxies) do
  #   if Map.has_key?(proxies, proxy) do
  #     {:noreply, proxies}
  #   else
  #     {:ok, proxy} = Gateway.Proxy.start_link([])
  #     {:noreply, Map.put(proxies, proxy, proxy)}
  #   end
  # end
end
