defmodule Ews do
  use Application.Behaviour

  def start(_type, _args) do
    Logger.start()
    EWS.Eval.Client.start()

    routes = [
      {"/", Ews.RootHandler, []},
      {"/websocket", Ews.WebsocketHandler, []},
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
    Ews.Supervisor.start_link
  end
end
