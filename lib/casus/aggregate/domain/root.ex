defprotocol Casus.Aggregate.Domain.Root do
  @moduledoc """
  The Casus.Aggregate.Domain.Root protocol.

  Implemented by an adapter to standardise all Root Domain Modules behaviour.
  The protocol is implemented on a struct representing the aggregate root identity.
  This is the struct that will be used to guaranty the uniqueness of the aggregate process in the cluster.
  """

  @typedoc """
  Struct representing the identity of the aggregate root.
  Usually a simple struct is enough. Like if the name of the domain root module is `Mission`, a struct named
  %Mission{} and with one id parameter `{id: "uuid-sting"}` is a nice way to implement the protocol.

  It is a way to use protocols as extension on modules and not structs.
  """
  @type aggregate_id :: struct
  @typedoc "A struct containing all the params necessary to dispatch a command to the aggregate."
  @type command :: struct
  @typedoc """
  A struct containing all the data necessary to represent an event that happened to the aggregate.
  The event should implement the Casus.AggregateModule.Event Protocol to manage the adaptation to the storage part.
  """
  @type event :: struct
  @typedoc "A struct containing all the data necessary to represent the state of the aggregate."
  @type state :: struct

  @doc """
  Function used to initialize the state of the aggregate.
  """
  @spec init_state(aggregate_id) :: state
  def init_state(aggregate_id)

  @doc """
  Function used to dispatch a command to an aggregate represented by it's state.
  """
  @spec handle(aggregate_id, command, state) :: {:ok, [event]} | {:error, reason :: term}
  def handle(aggregate_id, command, state)

  @doc """
  Function used to apply an event to a aggregate state.
  """
  @spec apply(aggregate_id, event, state) :: state
  def apply(aggregate_id, event, state)

  @doc """
  Function used to represent the aggregate id as a standardised struct of strings.
  """
  @spec to_raw_id(aggregate_id) :: Casus.Aggregate.Infra.RootRawId.t
  def to_raw_id(aggregate_id)

  @doc """
  Function used to represent the aggregate id as a String.
  ex : `Mission-2345-4567`
  """
  @spec to_string(aggregate_id) :: String.t
  def to_string(aggregate_id)
end
