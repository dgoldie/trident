defmodule Auth.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug fn -> "Application starting...Auth" end

    # List all child processes to be supervised
    children = [
      # Starts a worker by calling: Auth.Worker.start_link(arg)
      # {Auth.Worker, arg},
      {Auth.DataStore, %{}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Auth.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
