defmodule Mix.Tasks.Server do
  use Mix.Task

  @shortdoc "Run ews server"
  @recursive true

  @moduledoc """
  Runs ews server
  """

  def run(args) do
    Mix.Task.run "app.start", args
    :timer.sleep(:infinity)
  end
end

