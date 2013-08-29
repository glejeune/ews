defmodule Logger do
  def start() do
    :lager.start()
  end

  def debug(message, params // []) do
    :lager.log(:debug, self, message, params)
  end
  def info(message, params // []) do
    :lager.log(:info, self, message, params)
  end
  def notice(message, params // []) do
    :lager.log(:notice, self, message, params)
  end
  def warning(message, params // []) do
    :lager.log(:warning, self, message, params)
  end
  def error(message, params // []) do
    :lager.log(:error, self, message, params)
  end
  def alert(message, params // []) do
    :lager.log(:alert, self, message, params)
  end
  def emergency(message, params // []) do
    :lager.log(:emergency, self, message, params)
  end
end
