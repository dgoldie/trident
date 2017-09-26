# Trident.Umbrella

## Getting started

### Setup
Target apps, proxies and policies are configured in:
> in apps/gateway/config/config.exs

Demo users are configured in:
> apps/directory/config/config.exs

### Run
Run target apps on their configured localhost port.

To run trident
```
in the trident_umbrella directory
$ mix deps.get
$ mix compile
$ iex -S mix run --no-halt
```
