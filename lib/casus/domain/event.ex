defprotocol Casus.Domain.Event do
  @moduledoc """
  The Casus.Domain.Event protocol.

  Implemented by an adapter to allow Domain Events to be saved.
  The domain event is adapted to a map / or another struct implementing the JASON.encoder protocol.
  """

  @typedoc "A struct containing all the data necessary to represent an event that happened to the aggregate."
  @type event :: struct
  @typedoc "A raw event form that contains the event data in a form that implements JASON.encoder protocol."
  @type raw_event :: term
  @typedoc "A data form that contains the event data. (a string-key map most likely, see JASON documentation)"
  @type data :: term

  @doc "Converts a domain event to a raw data form that implements JASON.encoder protocol."
  @spec convert_to_raw(event) :: raw_event
  def convert_to_raw(event)

  @doc "Hydrate the empty_event struct with the data from the event store."
  @spec convert_from_raw(event, data) :: event
  def convert_from_raw(empty_event, data)
end
