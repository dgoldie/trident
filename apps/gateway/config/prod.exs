use Mix.Config

config :gateway,
  proxies: [
             %{port: 4000,
               to:   "http://google.com"},
             %{port: 4001,
               to:   "http://yahoo.com"}
            ],
  timeout: 20_000, # ms
  record: true,
  play: false,
  export_path: "test/example",
  play_path: "test/data"

config :logger, :console,
  format: "\n$date $time [$level] $metadata$message",
  metadata: [:user_id],
  level: :error
