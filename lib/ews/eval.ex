defmodule EWS.Eval do
  def start() do
    start(IEx.boot_config(dot_iex_path: ""))
  end

  def start(config) do
    :application.start(:iex)
    IEx.Options.set :colors, enabled: false

    { _, _, scope } = :elixir.eval('require IEx.Helpers', [], 0, config.scope)
    config.scope(scope)
  end

  def eval(code, config) do
    try do
      case do_eval(code, config) do
        {:nodata, config} -> {:nodata, config}
        {:data, data, config} -> {:data, data, config}
        _ -> {:error, "** (error) EWS unknown error"}
      end
    catch
      kind, error -> 
        {:error, "** (#{kind}) #{inspect(Exception.normalize(kind, error))}", config.cache('')}
    end
  end

  def do_eval(latest_input, config) do
    line_no = config.counter
    code = config.cache ++ '\n' ++ latest_input
    data = nil

    case :elixir_translator.forms(code, line_no, "iex", []) do
      { :ok, forms } ->
        { result, new_binding, scope } =
          :elixir.eval_forms(forms, config.binding, config.scope)

        unless result == IEx.dont_display_result do
          data = inspect(result)
        end

        config = config.cache(code).scope(nil).result(result)
        config = config.update_counter(&1+1).cache('').binding(new_binding).scope(scope).result(nil)
        case data do
          nil -> {:nodata, config}
          _ -> {:data, data, config}
        end

      { :error, { line_no, error, token } } ->
        if token == [] do
          # Update config.cache so that IEx continues to add new input to
          # the unfinished expression in `code`
          config = config.cache(code)
          {:nodata, config}
        else
          # Encountered malformed expression
          :elixir_errors.parse_error(line_no, "iex", error, token)
        end
    end
  end
end

defmodule EWS.Eval.Server do
  def start do
    spawn_link(__MODULE__, :run, [EWS.Eval.start()])
  end

  def run(config) do
    receive do
      {:code, code, sender} -> 
        case EWS.Eval.eval(code, config) do
          {type, message, config} -> 
            sender <- {type, message}
            run(config)
          {type, config} ->
            sender <- {type}
            run(config)
        end
      {:prompt, sender} ->
        sender <- {:prompt, "ews(#{config.counter})> "}
        run(config)
      {:count, sender} ->
        sender <- {:count, config.counter}
        run(config)
      _ -> run(config)
    end
  end
end

defmodule EWS.Eval.Client do
  def start(), do: start(:sandbox)
  def start(uuid) when is_list(uuid), do: start(list_to_atom(uuid))
  def start(uuid) when is_binary(uuid), do: start(binary_to_atom(uuid))
  def start(uuid) when is_atom(uuid) do
    pid = EWS.Eval.Server.start()
    Process.register(pid, uuid)
  end

  def run(code) do
    run(code, :sandbox)
  end
  def run(code, uuid) do
    Logger.info("Run command `#{code}' for UUID #{uuid}")
    code = case Data.type(code) do
      :binary -> String.to_char_list!(code)
      :bitstring -> String.to_char_list!(code)
      :list -> code
      _ -> raise "Invalid code type"
    end
    uuid = case Data.type(uuid) do
      :list -> list_to_atom(uuid)
      :binary -> binary_to_atom(uuid)
      :bitstring -> binary_to_atom(uuid)
      :atom -> uuid
      _ -> raise "Invalid uuid type"
    end

    uuid <- {:code, code, self}
    receive do
      all -> all
    end
  end

  def prompt(), do: prompt(:sandbox)
  def prompt(uuid) when is_list(uuid), do: prompt(list_to_atom(uuid))
  def prompt(uuid) when is_binary(uuid), do: prompt(binary_to_atom(uuid))
  def prompt(uuid) when is_bitstring(uuid), do: prompt(binary_to_atom(uuid))
  def prompt(uuid) when is_atom(uuid) do
    Logger.info("Prompt for UUID #{uuid}")
    uuid <- {:prompt, self}
    receive do
      {:prompt, prompt} -> prompt
    end
  end

  def count(), do: count(:sandbox)
  def count(uuid) when is_list(uuid), do: count(list_to_atom(uuid))
  def count(uuid) when is_binary(uuid), do: count(binary_to_atom(uuid))
  def count(uuid) when is_bitstring(uuid), do: count(binary_to_atom(uuid))
  def count(uuid) when is_atom(uuid) do
    Logger.info("Count for UUID #{uuid}")
    uuid <- {:count, self}
    receive do
      {:count, value} -> value
    end
  end
end

#EWS.Eval.Client.start()
#IO.puts EWS.Eval.Client.prompt
#IO.puts EWS.Eval.Client.count
#IO.inspect EWS.Eval.Client.run('a = "Hello"')
#IO.puts EWS.Eval.Client.count
#IO.inspect EWS.Eval.Client.run('"a = " <> a')

