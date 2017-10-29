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
      extra_applications: [:logger, :cowboy, :plug, :httpotion],
      mod: {Gateway.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4"},
      # {:plug, path: "/Users/doug/code/work/libraries/plug"},
      {:poison, "~> 3.1"},
      # {:httpoison, "~> 0.13"},
      {:httpotion, "~> 3.0.2"},
      # {:httpotion, path: "/Users/doug/code/work/libraries/httpotion"},
      {:fuzzyurl, "~> 0.9.0"},
      {:credo, "~> 0.8", only: [:dev, :test], runtime: false}
    ]
  end
end
