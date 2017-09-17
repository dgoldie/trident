defmodule Gateway.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug fn -> "Application starting...Gateway" end
    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Gateway.Worker.start_link(arg)
      # {Gateway.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Gateway.Proxy.Supervisor]
    Gateway.Proxy.Supervisor.start_link
  end
end
