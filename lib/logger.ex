defmodule Logger do
  defdelegate [start(), log(level, pid, message, params)], to: :lager

  def debug(message, params // [], pid // self) do
    log(:debug, pid, message, params)
  end
  def info(message, params // [], pid // self) do
    log(:info, pid, message, params)
  end
  def notice(message, params // [], pid // self) do
    log(:notice, pid, message, params)
  end
  def warning(message, params // [], pid // self) do
    log(:warning, pid, message, params)
  end
  def error(message, params // [], pid // self) do
    log(:error, pid, message, params)
  end
  def alert(message, params // [], pid // self) do
    log(:alert, pid, message, params)
  end
  def emergency(message, params // [], pid // self) do
    log(:emergency, pid, message, params)
  end
end
