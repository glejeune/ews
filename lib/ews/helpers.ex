defmodule EWS.Helpers do
  def session(uuid) do
  	uuid_atom = case Data.type(uuid) do
      :list -> list_to_atom(uuid)
      :binary -> binary_to_atom(uuid)
      :bitstring -> binary_to_atom(uuid)
      :atom -> uuid
      _ -> raise "Invalid uuid type"
    end

  	case Process.whereis(uuid_atom) do 
  		nil -> {:helper, [error: "** session #{uuid} not found!"]}
  		_ -> {:helper, [uuid: uuid]}
  	end
  end

  def about() do
    {:helper, [info: 
      "EWS version #{EWS.version} on Elixir #{System.version}\n" <>
      "Copyright (c)2013, Grégoire Lejeune <gregoire.lejeune@free.fr>"
    ]}
  end
end
