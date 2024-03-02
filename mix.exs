defmodule HttpParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :dumb_http_parser,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),

      name: "HTTP Parser",
      description: "Parse HTTP requests",
      source_url: "https://github.com/matteac/elixir_http_parser",
      docs: [
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
    ]
  end

  defp package do
    [
      maintainers: ["Mateo Acuña"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/matteac/elixir_http_parser"}
    ]
  end
end
