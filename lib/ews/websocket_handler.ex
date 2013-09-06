defmodule EWS.WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  def init({:tcp, :http}, _request, _options) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_transportName, request, _options) do
    uuid = UUID.generate
    EWS.Eval.Client.start(uuid)

    :erlang.start_timer(100, self, Jsonex.encode([hello: "Elixir Web Shell #{EWS.version} (Elixir #{System.version})", prompt: EWS.Eval.Client.prompt(uuid), uuid: "#{uuid}"]))
    {:ok, request, :undefined_state, :hibernate}
  end

  def websocket_handle({:text, message}, request, state) do
    json = Jsonex.decode(message)
    uuid = Dict.get(json, "uuid")
    command = Dict.get(json, "command")
    Logger.info("#{uuid} send command `#{command}'")

    helper_response = try do
      case Code.string_to_quoted(command) do
        {:ok, {fname, _, params}} -> 
          if Code.ensure_loaded?(EWS.Helpers) and is_atom(fname) do
            Logger.info("Search function EWS.Herlpers.#{fname}/#{length(params || [])}")
            if function_exported?(EWS.Helpers, fname, length(params || [])) do
              Logger.info("Found function EWS.Herlpers.#{fname}/#{length(params || [])}")
              apply(EWS.Helpers, fname, params || [])
            else
              Logger.info("Function EWS.Herlpers.#{fname}/#{length(params || [])} not found")
              :continue
            end
          else
            :continue
          end
        _ ->
          :continue
      end
    rescue
      e -> {:helper, [error: "** Internal server error: #{e.message}\n#{Exception.format_stacktrace(System.stacktrace)}"]}
    end

    response = case helper_response do
      {:helper, data} -> data
      :continue -> case EWS.Eval.Client.run(command, uuid) do
        {:nodata} -> 
          []
        {:data, data} -> 
          [result: data]
        {:error, error} ->
          [error: error]
        _ ->
          [error: "** Internal Server error"]
      end
      _ ->
        [error: "** Internal Server error"]
    end
    new_uuid = Dict.get(response, :uuid, uuid)
    response = response ++ [prompt: EWS.Eval.Client.prompt(new_uuid)]
    
    Logger.info("Response for #{uuid}: #{inspect(response)}")

    {:reply, {:text, Jsonex.encode(response)}, request, state, :hibernate}
  end
  def websocket_handle(_data, request, state) do
    {:ok, request, state, :hibernate}
  end

  def websocket_info({:timeout, _ref, message}, request, state) do
    Logger.info("websocket_info : #{message}")
    {:reply, {:text, message}, request, state, :hibernate}
  end
  def websocket_info(_info, request, state) do
    {:ok, request, state, :hibernate}
  end

  def websocket_terminate(_reason, _request, _state) do
    Logger.info("websocket_terminate")
    :ok
  end
end
