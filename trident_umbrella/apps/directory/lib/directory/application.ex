defmodule Directory.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  require Logger

  def start(_type, _args) do
    Logger.debug fn -> "Application starting...Directory" end
    # List all child processes to be supervised
    children = [
      {Directory.DataStore, %{}}
      # Starts a worker by calling: Directory.Worker.start_link(arg)
      # {Directory.Worker, arg},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Directory.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # def start do
  #   Logger.debug fn -> "Directory other start" end
  #   Directory.seed_users
  # end
end
