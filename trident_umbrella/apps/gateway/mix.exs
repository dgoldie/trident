defmodule Gateway.Mixfile do
  use Mix.Project

  def project do
    [
      app: :gateway,
      version: "0.1.0",
      elixir: "~> 1.6-dev",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :cowboy, :plug, :httpoison],
      mod: {Gateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.0"},
      {:plug, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 0.13"},
      {:fuzzyurl, "~> 0.9.0"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
