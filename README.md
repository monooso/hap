# Hap
Hap is a real-time monitoring tool for your most important business metrics. Or least important, it's really up to you. I'm building it [live on Twitch](https://twitch.tv/stephencodes).

## Building and running
Hap requires Elixir and PostgreSQL. Install them however you wish.

To get started:

1. Clone the repository.
2. Run `mix deps.get` to install the dependencies.
3. Run `mix ecto.setup` to create and migrate the database.
4. Start the development server with `mix phx.server` or `iex -S mix phx.server`.
5. Visit [`localhost:4000`](http://localhost:4000), and behold the glory.
