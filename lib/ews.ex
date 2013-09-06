defmodule EWS do
  use Application.Behaviour

  def version, do: "0.0.2-dev"
  
  def start(_type, _args) do
    Logger.start()
    EWS.Eval.Client.start()

    routes = [
      {"/", EWS.RootHandler, []},
      {"/websocket", EWS.WebsocketHandler, []},
      {"/static/[...]", :cowboy_static, [
        {:directory, {:priv_dir, :ews, ["static"]}},
        {:mimetypes, {&:mimetypes.path_to_mimes/2, :default}}
      ]}
    ]
    dispatch = :cowboy_router.compile([{:_, routes}])
    {:ok, _} = :cowboy.start_http(:http, 100,
                                  [port: 8080],
                                  [env: [dispatch: dispatch]])
    Logger.info("** Server started on port 8080")
    EWS.Supervisor.start_link
  end
end
