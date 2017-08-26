use Mix.Config

# Configure your database
config :trident, Trident.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trident_dev",
  hostname: "localhost",
  pool_size: 10
