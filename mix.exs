defmodule Casus.MixProject do
  use Mix.Project

  def project do
    [
      app: :casus,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      spec_paths: ["spec"],
      spec_pattern: "*_spec.exs",
      preferred_cli_env: [
        espec: :test
      ],
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Casus.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:espec, "~> 1.7.0", only: :test},
      {:ersatz, "~> 0.1.1", only: :test}
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "spec/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp aliases do
    [
      test: ["espec"],
      espec: ["espec"]
    ]
  end
end
