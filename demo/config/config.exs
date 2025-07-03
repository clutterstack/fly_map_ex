# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :demo,
  generators: [timestamp_type: :utc_datetime],
  # Configure your Fly.io app name here
  fly_app_name: nil

# FlyMapEx opacity and radius configuration
config :fly_map_ex,
  marker_opacity: 1.0,
  hover_opacity: 0.9,
  animation_opacity_range: {0.4, 1.0},
  # region_marker_radius: 3,
  marker_base_radius: 9,
  default_theme: :responsive,
  custom_themes: %{
    corporate: %{
      land: "#f8fafc",
      ocean: "#e2e8f0",
      border: "#475569",
      neutral_marker: "#64748b",
      neutral_text: "#334155"
    },
    sunset: %{
      land: "#fef3c7",
      ocean: "#fbbf24",
      border: "#d97706",
      neutral_marker: "#b45309",
      neutral_text: "#92400e"
    }
  }

# Configures the endpoint
config :demo, DemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: DemoWeb.ErrorHTML, json: DemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Demo.PubSub,
  live_view: [signing_salt: "WsN2PQ4I"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  demo: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.0.9",
  demo: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
