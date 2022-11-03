# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
import Config

config :indexer,
  ecto_repos: [Explorer.Repo]

# config :indexer, Indexer.Fetcher.ReplacedTransaction.Supervisor, disabled?: true
config :indexer, Indexer.Fetcher.BlockReward.Supervisor,
  disabled?: System.get_env("INDEXER_DISABLE_BLOCK_REWARD_FETCHER", "false") == "true"

config :indexer, Indexer.Fetcher.InternalTransaction.Supervisor,
  disabled?: System.get_env("INDEXER_DISABLE_INTERNAL_TRANSACTIONS_FETCHER", "false") == "true"

config :indexer, Indexer.Fetcher.CoinBalance.Supervisor,
  disabled?: System.get_env("INDEXER_DISABLE_ADDRESS_COIN_BALANCE_FETCHER", "false") == "true"

config :indexer, Indexer.Fetcher.TokenUpdater.Supervisor,
  disabled?: System.get_env("INDEXER_DISABLE_CATALOGED_TOKEN_UPDATER_FETCHER", "false") == "true"

config :indexer, Indexer.Fetcher.EmptyBlocksSanitizer.Supervisor,
  disabled?: System.get_env("INDEXER_DISABLE_EMPTY_BLOCK_SANITIZER", "false") == "true"

config :indexer, Indexer.Fetcher.ENSName.Supervisor,
  disabled?:
    !(System.get_env("ENABLE_ENS") == "true" &&
        (System.get_env("ENS_REGISTRY_ADDRESS") != nil || System.get_env("ENS_RESOLVER_ADDRESS") != nil))

config :indexer, Indexer.Supervisor, enabled: System.get_env("DISABLE_INDEXER") != "true"

config :indexer, Indexer.Tracer,
  service: :indexer,
  adapter: SpandexDatadog.Adapter,
  trace_key: :blockscout

config :logger, :indexer,
  # keep synced with `config/config.exs`
  format: "$dateT$time $metadata[$level] $message\n",
  metadata:
    ~w(application fetcher request_id first_block_number last_block_number missing_block_range_count missing_block_count
       block_number step count error_count shrunk import_id transaction_id)a,
  metadata_filter: [application: :indexer]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
