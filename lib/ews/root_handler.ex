defmodule EWS.RootHandler do
  def init(_transport, req, [config]) do
    {host_ip, _} = :cowboy_req.host(req)
    {:ok, req, {host_ip, config.http_port}}
  end

  def handle(req, state) do
    html = get_html(state)
    {:ok, req} = :cowboy_req.reply(200, [{"content-type", "text/html"}], html, req)
    {:ok, req, state}
  end

  def terminate(_reason, _req, _state) do
    :ok
  end

  defp get_html(state) do
    {host_ip, host_port} = state
    {:ok, cwd} = File.cwd()
    path = Path.join([cwd, "priv", "index.html"])
    EEx.eval_file path, [port: host_port, host: host_ip]
    #{:ok, html} = File.read(path)
    #html
  end
end
