defmodule Casus.Aggregate.Event do
  @moduledoc """
  The struct specifying the Aggregate application vision about an event.

  id                 : an uuid for the event
  aggregate_id       : struct representing the identity of the domain aggregate root.
  event              : struct produced by the aggregate domain module
  event_timestamp    : timestamp of when the event happened in the system
  """

  @type id :: String.t
  @type aggregate_id :: struct
  @type event :: struct
  @type event_timestamp :: DateTime.t

  @type t :: %Casus.Aggregate.Event {
               id: id,
               aggregate_id: aggregate_id,
               event: event,
               timestamp: event_timestamp
             }

  @enforce [:id, :aggregate_id, :event, :timestamp]
  defstruct [:id, :aggregate_id, :event, :timestamp]
end