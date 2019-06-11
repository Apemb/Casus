defmodule Casus.Aggregate.Dependency.EventStore do
  @moduledoc """
  The behaviour specifying the Aggregate expectation concerning the event store.
  """

  @type aggregate_id :: Casus.Aggregate.Infra.RootRawId.t
  @type event :: Casus.Aggregate.Infra.Event.t

  @doc "The callback to init the event store, giving control of the initialization moment to the controlling app"
  @callback initialize() :: :ok | {:error, reason :: term}

  @doc "Get all events for the aggregate in order"
  @callback get_history(aggregate_id) :: {:ok, [event]} | {:error, reason :: term}

  @doc "Save events for a specific aggregate"
  @callback save([event]) :: :ok | {:error, reason :: term}
end
