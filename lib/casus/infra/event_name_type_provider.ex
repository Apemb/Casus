defmodule Casus.Infra.EventNameTypeProvider do
  @moduledoc """
  Behaviour to provide the conversion between the event struct and a corresponding string type.
  One can provide its own implementation of this converter and set it using a env variable as follows:

      config :casus, type_provider: CustomEventNameTypeProviderModule

  If not overridden it will use the default event name type provider.

  ## Default Event Name Type Provider

  It only works with Event struct that have a module name that goes :
      Elixir.(BoundedContext).(Aggregate).Event.(EventName)

  ### Example
  ```
  event = %Elixir.Blog.Post.Event.PostCreated{}
  type = Casus.AggregateInfra.DefaultEventNameTypeProvider.to_type(event)

  type == %Casus.Infra.EventType{
      context_name: "Blog",
      aggregate_name: "Post",
      event_name: "Post",
      version: "1"
    }
  ```
  """

  @type event :: struct
  @type event_type :: Casus.Infra.EventType.t

  @doc """
  convert the given event struct to an EventType struct
  """
  @callback to_type(event) :: event_type

  @doc """
  Convert the given EventType struct to the corresponding event struct (event struct is expected to be with no data)
  """
  @callback to_struct(event_type) :: event

  @doc false
  @spec to_type(event) :: event_type
  def to_type(struct), do: type_provider().to_type(struct)

  @doc false
  @spec to_struct(event_type) :: event
  def to_struct(type), do: type_provider().to_struct(type)

  @doc false
  def type_provider do
    Application.get_env(:casus, :type_provider, Casus.Infra.DefaultEventNameTypeProvider)
  end
end
