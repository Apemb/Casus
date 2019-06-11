defmodule Casus.Aggregate.Infra.Event do
  @moduledoc """
  The struct specifying the Aggregate application vision about a raw event to use in persisting the events.
  This is a JSON encodable struct.

  id                 : an uuid for the event
  aggregate_id       : the standardised representation of an aggregate id
  event_data         : arbitrary data given by the domain module, is JASON.encodable
  event_type         : representation of the type of the event
  event_timestamp    : timestamp of when the event happened in the system
  """

  @type id :: String.t
  @type aggregate_id ::Casus.Aggregate.Infra.RootRawId.t
  @type event_type ::Casus.Aggregate.Infra.EventType.t
  @type event_data :: struct
  @type event_timestamp :: DateTime.t

  @type t :: %Casus.Aggregate.Infra.Event {
               id: id,
               aggregate_id: aggregate_id,
               event_type: event_type,
               event_data: event_data,
               event_timestamp: event_timestamp
             }

  @enforce [:id, :aggregate_id, :event_type, :event_data, :event_timestamp]
  defstruct [:id, :aggregate_id, :event_type, :event_data, :event_timestamp]
end