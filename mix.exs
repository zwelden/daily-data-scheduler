defmodule AssistABot.MixProject do
  use Mix.Project

  def project do
    [
      app: :assist_a_bot,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:taskerville, "~> 0.0.1"},
      {:httpoison, "~> 1.8"},
      {:poison, "~> 3.1"},
      {:decimal, "~> 2.0"}
    ]
  end
end
