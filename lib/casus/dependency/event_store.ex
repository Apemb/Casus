defmodule Casus.Dependency.EventStore do
  @moduledoc """
  The behaviour specifying the Aggregate expectation concerning the event store.

  Should be set using config file as follows :

      config :casus, event_store: EventStoreModule
  """

  @doc "The callback to init the event store, giving control of the initialization moment to the controlling app"
  @callback initialize() :: :ok | {:error, reason :: term}

  @doc "Get all events for the aggregate in order"
  @callback get_history(aggregate_id :: Casus.Infra.RootRawId.t) ::
              {:ok, [event :: Casus.Infra.Event.t]} |
              {:error, reason :: term}

  @doc "Save events for a specific aggregate"
  @callback save([event :: Casus.Infra.Event.t]) :: :ok | {:error, reason :: term}
end
