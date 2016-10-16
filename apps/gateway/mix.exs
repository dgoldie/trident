defmodule Gateway.Mixfile do
  use Mix.Project

  def project do
    [app: :gateway,
     version: "0.1.0",
     elixir: "~> 1.3",
     name: "TridentGateway",
     source_url: "https://github.com/dgoldie/trident",
     description: "Multi port HTTP Proxy and support record/play request.",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps(),
     package: package(),
     aliases: aliases(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test],
     preferred_cli_env: [
          vcr: :test, "vcr.delete": :test, "vcr.check": :test, "vcr.show": :test
        ],
     docs: docs()
   ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [
      applications: [:logger, :cowboy, :plug, :hackney],
      mod: {Gateway, []}
    ]
  end

  defp aliases do
    [
      proxy: ["run --no-halt"],
      test: ["coveralls"]
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:cowboy, "~> 1.0.0" },
      {:plug, "~> 1.0"},
      {:hackney, "~> 1.6"},
      {:exjsx, "~> 3.2"},
      {:earmark, "~> 1.0", only: :dev},
      {:ex_doc, "~> 0.13", only: :dev},
      {:exvcr, "~> 0.7", only: :test},
      {:ex_parameterized, "~> 1.0", only: :test},
      {:excoveralls, "~> 0.5", only: :test},
      {:credo, "~> 0.3", only: [:dev, :test]},
      {:dialyxir, "~> 0.3", only: :dev},
      {:shouldi, "~> 0.3", only: :test}
    ]
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Doug Goldie", "Joe Kain", "Hemant Thakker"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/dgoldie/gateway"}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md",
        "README.md"
      ]
    ]
  end


end
