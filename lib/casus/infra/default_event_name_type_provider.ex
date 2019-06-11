defmodule Casus.Infra.DefaultEventNameTypeProvider do
  @moduledoc """
  Default event name type provider.

  It only works with Event struct that have a module name that goes :
    `Elixir.(BoundedContext).(Aggregate).Event.(EventName)`

  ## Example
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

  @behaviour Casus.Infra.EventNameTypeProvider
  @regex_string "Elixir\\.(?<context>[A-Za-z.]*?)\\.(?<aggregate>[A-Za-z]+)\\.Event\\.(?<event>[A-Za-z]+)"

  def to_type(event) do

    {:ok, regex} = Regex.compile(@regex_string)

    string_module_name = event.__struct__
                         |> Atom.to_string()

    named_captures = Regex.named_captures(regex, string_module_name)

    context_name = Map.get(named_captures, "context")
    aggregate_name = Map.get(named_captures, "aggregate")
    event_name = Map.get(named_captures, "event")
    version = "1"

    %Casus.Infra.EventType{
      context_name: context_name,
      aggregate_name: aggregate_name,
      event_name: event_name,
      version: version
    }
  end

  def to_struct(%Casus.Infra.EventType{} = type) do
    struct_module = @regex_string
                    |> String.replace("\\.", ".")
                    |> String.replace("(?<context>[A-Za-z.]*?)", type.context_name)
                    |> String.replace("(?<aggregate>[A-Za-z]+)", type.aggregate_name)
                    |> String.replace("(?<event>[A-Za-z]+)", type.event_name)
                    |> String.to_existing_atom()

    Kernel.struct(struct_module)
  end
end
