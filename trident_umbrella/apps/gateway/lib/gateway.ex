defmodule Gateway do
  @moduledoc """
  Documentation for Gateway.
  """

  use Application
  alias Gateway.Proxy.Supervisor, as: ProxySup

  @spec start(:normal, []) :: {:ok, pid}
  def start(_type, _args) do
    ProxySup.start_link
  end

  @doc """
  Stop gateway.
  """
  @spec stop :: :ok | {:error, term}
  def stop do
    Application.stop :ranch
    Application.stop :cowlib
    Application.stop :cowboy
    Application.stop :idna
    # Application.stop :mimerl
    # Application.stop :certifi
    Application.stop :httpoison
    Application.stop :plug
    Application.stop :gateway
  end

  @doc """
  Start gateway.
  If the proxy is already running, return `{:error, {:already_started, :gateway}}`
  """
  @spec start() :: :ok | {:error, term}
  def start do
    Application.start :ranch
    Application.start :cowlib
    Application.start :cowboy
    Application.start :idna
    # Application.start :mimerl
    # Application.start :certifi
    Application.start :httpoison
    Application.start :plug
    Application.start :gateway
  end
end





