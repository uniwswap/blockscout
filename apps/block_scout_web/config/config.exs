# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

network_path =
  "NETWORK_PATH"
  |> System.get_env("/")
  |> (&(if !String.ends_with?(&1, "/") do
          &1 <> "/"
        else
          &1
        end)).()

api_path =
  "API_PATH"
  |> System.get_env("/")
  |> (&(if !String.ends_with?(&1, "/") do
          &1 <> "/"
        else
          &1
        end)).()

# General application configuration
config :block_scout_web,
  namespace: BlockScoutWeb,
  ecto_repos: [Explorer.Repo, Explorer.Repo.Account]

config :block_scout_web,
  link_to_other_explorers: System.get_env("LINK_TO_OTHER_EXPLORERS") == "true",
  other_explorers: System.get_env("OTHER_EXPLORERS"),
  other_networks: System.get_env("SUPPORTED_CHAINS"),
  webapp_url: System.get_env("WEBAPP_URL"),
  api_url: System.get_env("API_URL"),
  apps_menu: if(System.get_env("APPS_MENU", "false") == "true", do: true, else: false),
  external_apps: System.get_env("EXTERNAL_APPS"),
  gas_price: System.get_env("GAS_PRICE", nil),
  restricted_list: System.get_env("RESTRICTED_LIST", nil),
  restricted_list_key: System.get_env("RESTRICTED_LIST_KEY", nil),
  dark_forest_addresses: System.get_env("CUSTOM_CONTRACT_ADDRESSES_DARK_FOREST"),
  dark_forest_addresses_v_0_5: System.get_env("CUSTOM_CONTRACT_ADDRESSES_DARK_FOREST_V_0_5"),
  circles_addresses: System.get_env("CUSTOM_CONTRACT_ADDRESSES_CIRCLES"),
  test_tokens_addresses: System.get_env("CUSTOM_CONTRACT_ADDRESSES_TEST_TOKEN"),
  max_size_to_show_array_as_is: Integer.parse(System.get_env("MAX_SIZE_UNLESS_HIDE_ARRAY", "50")),
  max_length_to_show_string_without_trimming: System.get_env("MAX_STRING_LENGTH_WITHOUT_TRIMMING", "2040"),
  re_captcha_secret_key: System.get_env("RE_CAPTCHA_SECRET_KEY", nil),
  re_captcha_client_key: System.get_env("RE_CAPTCHA_CLIENT_KEY", nil),
  admin_panel_enabled: System.get_env("ADMIN_PANEL_ENABLED", "") == "true",
  ens_metadata_server: System.get_env("ENS_METADATA_SERVER", nil)

config :block_scout_web, BlockScoutWeb.Counters.BlocksIndexedCounter, enabled: true

# Configures the endpoint
config :block_scout_web, BlockScoutWeb.Endpoint,
  url: [
    path: network_path,
    api_path: api_path
  ],
  render_errors: [view: BlockScoutWeb.ErrorView, accepts: ~w(html json)],
  pubsub_server: BlockScoutWeb.PubSub

config :block_scout_web, BlockScoutWeb.Tracer,
  service: :block_scout_web,
  adapter: SpandexDatadog.Adapter,
  trace_key: :blockscout

# Configures gettext
config :block_scout_web, BlockScoutWeb.Gettext, locales: ~w(en), default_locale: "en"

config :block_scout_web, BlockScoutWeb.SocialMedia,
  twitter: "PoaNetwork",
  telegram: "poa_network",
  facebook: "PoaNetwork",
  instagram: "PoaNetwork"

config :block_scout_web, BlockScoutWeb.Chain.TransactionHistoryChartController,
  # days
  history_size: 30

config :ex_cldr,
  default_locale: "en",
  default_backend: BlockScoutWeb.Cldr

config :logger, :block_scout_web,
  # keep synced with `config/config.exs`
  format: "$dateT$time $metadata[$level] $message\n",
  metadata:
    ~w(application fetcher request_id first_block_number last_block_number missing_block_range_count missing_block_count
       block_number step count error_count shrunk import_id transaction_id)a,
  metadata_filter: [application: :block_scout_web]

config :prometheus, BlockScoutWeb.Prometheus.Instrumenter,
  # override default for Phoenix 1.4 compatibility
  # * `:transport_name` to `:transport`
  # * remove `:vsn`
  channel_join_labels: [:channel, :topic, :transport],
  # override default for Phoenix 1.4 compatibility
  # * `:transport_name` to `:transport`
  # * remove `:vsn`
  channel_receive_labels: [:channel, :topic, :transport, :event]

config :spandex_phoenix, tracer: BlockScoutWeb.Tracer

config :wobserver,
  # return only the local node
  discovery: :none,
  mode: :plug

config :block_scout_web, BlockScoutWeb.ApiRouter,
  writing_enabled: System.get_env("DISABLE_WRITE_API") != "true",
  reading_enabled: System.get_env("DISABLE_READ_API") != "true",
  wobserver_enabled: System.get_env("WOBSERVER_ENABLED") == "true"

config :block_scout_web, BlockScoutWeb.WebRouter, enabled: System.get_env("DISABLE_WEBAPP") != "true"

# Configures Ueberauth local settings
config :ueberauth, Ueberauth,
  providers: [
    auth0: {
      Ueberauth.Strategy.Auth0,
      [callback_path: "/auth/auth0/callback"]
    }
  ]

config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4, cleanup_interval_ms: 60_000 * 10]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
