# EWS

[Elixir](http://elixir-lang.org) Web Shell

## Configuration

You can create a configuration file (`~/.ews.exs`) to specify the EWS port and IP binding. Example :

    EWSConfig.config do
      config.http_port 9090
      config.http_ip "0.0.0.0"
    end

## Start

    mix deps.get
    mix server
    # open http://localhost:8080

![](priv/static/ews.png)

## License

All files under this repository fall under the MIT License (see the file LICENSE). 

"Elixir" and the Elixir logo are copyright (c) 2012 Plataformatec.
