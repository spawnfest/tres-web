import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :inspector_daya, InspectorDayaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "5wrCiPBwag1pTaiHH3VBlRgPhgCdDD8xKqmPXF+ewvxvki4R1EQl6L663DZBI24t",
  server: false

# In test we don't send emails.
config :inspector_daya, InspectorDaya.Mailer, adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :tesla, :adapter, Tesla.Mock
