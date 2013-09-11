defmodule EWS do
  use Application.Behaviour

  def version, do: "0.0.2-dev"
  
  def start(_type, _args) do
    require EWSConfig
    Logger.start()
    EWS.Eval.Client.start()

    config_file = Path.join(Path.expand("~"), ".ews.exs")
    config = case File.exists?(config_file) do
      true -> EWSConfig.file! config_file
      false -> EWSConfig.config do
      end
    end

    routes = [
      {"/", EWS.RootHandler, [config]},
      {"/websocket", EWS.WebsocketHandler, []},
      {"/static/[...]", :cowboy_static, [
        {:directory, {:priv_dir, :ews, ["static"]}},
        {:mimetypes, {&:mimetypes.path_to_mimes/2, :default}}
      ]}
    ]
    dispatch = :cowboy_router.compile([{:_, routes}])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [
                                    port: config.http_port, 
                                    ip: EWSConfig.decode_ip(config.http_ip)
                                  ],
                                  [env: [dispatch: dispatch]])
    Logger.info("** EWS Server started on #{EWSConfig.encode_ip(config.http_ip)}:#{config.http_port}")
    EWS.Supervisor.start_link
  end
end
