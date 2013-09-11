defmodule EWSConfig do
  use ExConfig.Object
  defproperty http_port, default: 8080
  defproperty http_ip, default: {127,0,0,1}

  @doc false
  def decode_ip(ip) when is_tuple(ip), do: ip
  @doc false
  def decode_ip(ip) when is_list(ip), do: decode_ip(list_to_bitstring(ip))
  @doc false
  def decode_ip(ip) when is_binary(ip) do
    String.split(ip, ".")
    |> Enum.map(fn(x) -> binary_to_integer(x) end)
    |> list_to_tuple
  end
  @doc false
  def encode_ip(ip) when is_binary(ip), do: ip
  @doc false
  def encode_ip(ip) when is_list(ip), do: encode_ip(list_to_tuple(ip))
  @doc false
  def encode_ip(ip) when is_tuple(ip) do
    {a, b, c, d} = ip
    "#{a}.#{b}.#{c}.#{d}"
  end
end
