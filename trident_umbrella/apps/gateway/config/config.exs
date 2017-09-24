# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure your application as:
#
#     config :gateway, key: :value
#
# and access this configuration in your application as:
#
#     Application.get_env(:gateway, :key)
#
# You can also configure a 3rd-party app:
#
#     config :logger, level: :info
#

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
#     import_config "#{Mix.env}.exs"


config :gateway,
proxies: [
           %{port: 8085,
             to:   "http://localhost:3000",
             protected_routes: ["/visitors/*"]},
           %{port: 8086,
             to:   "http://localhost:3010",
             protected_routes: ["/about", "/visitors/**"]},
           %{port: 8090,
             to:   "http://localhost:4000",
             protected_routes: ["/documents", "/stylesheets", "/flyers"]},
           %{port: 8091,
             to:   "https://lit-island-51614.herokuapp.com/",
             protected_routes: ["/documents", "/stylesheets", "/flyers"]}

         ]
