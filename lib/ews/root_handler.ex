defmodule EWS.RootHandler do
  def init(_transport, req, [config]) do
    {:ok, req, config}
  end

  def handle(req, state) do
    html = get_html(state.http_port)
    {:ok, req} = :cowboy_req.reply(200, [{"content-type", "text/html"}], html, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp get_html(port) do
    {:ok, cwd} = File.cwd()
    path = Path.join([cwd, "priv", "index.html"])
    EEx.eval_file path, [port: port]
    #{:ok, html} = File.read(path)
    #html
  end
end
