defmodule EWS.Mixfile do
  use Mix.Project

  def project do
    [ app: :ews,
      version: "0.0.1",
      elixir: "~> 0.10.2-dev",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [
      mod: { EWS, [] },
      applications: [:cowboy],
      lager: [
        handlers: [
          lager_console_backend: :info,
          lager_file_backend: [file: "error.log", level: :error],
          lager_file_backend: [file: "console.log", level: :info]
        ]
      ]
    ]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "~> 0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [
      {:cowboy, github: "extend/cowboy"},
      {:mimetypes, github: "spawngrid/mimetypes"},
      {:lager, github: "basho/lager"},
      {:shakkei, github: "glejeune/shakkei"},
      {:jsonex, github: "marcelog/jsonex"},
      {:exconfig, github: "yrashk/exconfig"}
    ]
  end
end
