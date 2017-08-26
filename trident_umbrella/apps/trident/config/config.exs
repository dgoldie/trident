use Mix.Config

config :trident, ecto_repos: [Trident.Repo]

import_config "#{Mix.env}.exs"
