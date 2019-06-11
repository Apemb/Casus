use Mix.Config

config :casus, event_store: Mock.EventStore
config :casus, uuid: Mock.UUID
config :casus, time_stamper: Mock.TimeStamper
