use Mix.Config

# Configure your database
config :trident, Trident.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "trident_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
