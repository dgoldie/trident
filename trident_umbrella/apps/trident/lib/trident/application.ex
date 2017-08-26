defmodule Trident.Application do
  @moduledoc """
  The Trident Application Service.

  The trident system business domain lives in this application.

  Exposes API to clients such as the `TridentWeb` application
  for use in channels, controllers, and elsewhere.
  """
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    Supervisor.start_link([
      supervisor(Trident.Repo, []),
    ], strategy: :one_for_one, name: Trident.Supervisor)
  end
end
