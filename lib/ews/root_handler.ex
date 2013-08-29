defmodule Ews.RootHandler do
  def init(_transport, req, []) do
    {:ok, req, nil}
  end

  def handle(req, state) do
    html = get_html()
    {:ok, req} = :cowboy_req.reply(200, [{"content-type", "text/html"}], html, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp get_html() do
    {:ok, cwd} = File.cwd()
    path = Path.join([cwd, "priv", "index.html"])
    {:ok, html} = File.read(path)
    html
  end
end