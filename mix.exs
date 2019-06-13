defmodule Casus.MixProject do
  use Mix.Project

  @version "0.0.1"

  def project do
    [
      app: :casus,
      version: @version,
      name: "Casus",
      source_url: "https://github.com/apemb/casus",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env()),
      aliases: aliases(),
      spec_paths: ["spec"],
      spec_pattern: "*_spec.exs",
      preferred_cli_env: [
        espec: :test
      ],
      package: package(),
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Casus.Application, []}
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
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

  defp package do
    [
      description: "Event Sourcing light framework for Elixir",
      maintainers: [
        "Antoine Boileau"
      ],
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/apemb/casus"
      }
    ]
  end

  ## Documentation

  defp docs do
    [
      main: "Casus",
      source_ref: "v#{@version}",
      extras: extras(),
      groups_for_modules: groups_for_modules(),
    ]
  end

  defp extras do
    [
      "README.md"
    ]
  end

  defp groups_for_modules do
    # Ungrouped:
    # - Casus

    [
      "Aggregate": [
        Casus.Aggregate
      ],
      "Domain": [
        Casus.Domain.Event,
        Casus.Domain.Root
      ],
      "Dependencies": [
        Casus.Dependency.EventStore,
        Casus.Dependency.UUID
      ],
      "Infra": [
        Casus.Infra.Event,
        Casus.Infra.EventType,
        Casus.Infra.EventNameTypeProvider,
        Casus.Infra.RootRawId,
        Casus.Infra.TimeStamper
      ]
    ]
  end
end
