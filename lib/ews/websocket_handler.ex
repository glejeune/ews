defmodule Ews.WebsocketHandler do
  @behaviour :cowboy_websocket_handler

  defp quote_string(str) do
    String.replace(str, "\\", "\\\\") 
    |> String.replace("\"", "\\\"")
  end

  def init({:tcp, :http}, _request, _options) do
    {:upgrade, :protocol, :cowboy_websocket}
  end

  def websocket_init(_transportName, request, _options) do
    :erlang.start_timer(100, self, "{\"hello\":\"Elixir Web Shell (#{System.version})\", \"prompt\":\"#{EWS.Eval.Client.prompt}\"}")
    {:ok, request, :undefined_state, :hibernate}
  end

  def websocket_handle({:text, message}, request, state) do
    Logger.info("websocket_handle : #{message}")
    message = case EWS.Eval.Client.run(message) do
      {:nodata} -> 
        "{\"prompt\":\"#{EWS.Eval.Client.prompt}\"}"
      {:data, data} -> 
        "{\"prompt\":\"#{EWS.Eval.Client.prompt}\", \"result\":\""<>quote_string(data)<>"\"}"
      {:error, message} ->
        "{\"prompt\":\"#{EWS.Eval.Client.prompt}\", \"error\":\""<>quote_string(message)<>"\"}"
      _ ->
        "{\"prompt\":\"#{EWS.Eval.Client.prompt}\", \"error\":\"** Internal Server error\"}"
    end
    Logger.info("websocket_handle response : #{message}")

    {:reply, {:text, message}, request, state, :hibernate}
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
    :ok
  end
end
