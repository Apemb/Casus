defmodule Casus.Aggregate.Infra.EventType do
  @moduledoc """
  A struct representing the type of an event.

  An event type is four property :
  - a context, representing the name of the bounded context ex: "Calculator"
  - a aggregate name, representing the name of the aggregate it refers to ex: "Counter"
  - an event name, representing the name of that category of events ex: "CounterInitialized"
  - a version, representing the version of that specific category ex: "1"

  ## Example
  An event from the Calculator bounded context, related to the initialization of the aggregate Counter
  could have the following type:
  ```
  %Aggregate.Infra.EventType {
    context_name: "Calculator",
    aggregate_name: "Counter",
    event_name: "CounterInitialized",
    version: "1",
  }
  ```
  """

  @type t :: %Casus.Aggregate.Infra.EventType {
               context_name: String.t,
               aggregate_name: String.t,
               event_name: String.t,
               version: String.t
             }

  @enforce [:context_name, :aggregate_name, :event_name, :version]
  defstruct [:context_name, :aggregate_name, :event_name, :version]
end
