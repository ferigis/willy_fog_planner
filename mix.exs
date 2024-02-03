defmodule WillyFog.Planner.MixProject do
  use Mix.Project

  def project do
    [
      app: :willy_fog_planner,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer(),
      test_coverage: [
        tool: ExCoveralls
      ],
      preferred_cli_env: [
        check: :test,
        coveralls: :test,
        "coveralls.html": :test
      ]
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
      {:ecto, "~> 3.11"},
      {:timex, "~> 3.7"},

      # Tests
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18.0", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      check: [
        "format --check-formatted",
        "credo --strict",
        "coveralls.html",
        "dialyzer --format short"
      ]
    ]
  end

  defp dialyzer do
    [
      plt_add_apps: [:ecto, :mix, :eex, :ex_unit],
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
      flags: [
        :unmatched_returns,
        :error_handling,
        :no_opaque,
        :unknown,
        :no_return
      ]
    ]
  end
end
