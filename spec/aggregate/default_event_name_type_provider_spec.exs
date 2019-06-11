defmodule DefaultEventNameTypeProviderSpec do
  @moduledoc false

  use ESpec
  alias Casus.Aggregate


  describe "to_type" do

    context "with an event with a bounded context" do

      before do
        event = %Fixture.Counter.Event.CounterInitialized{id: "fake-uuid", initial_counter_value: 0}
        type = Aggregate.Infra.DefaultEventNameTypeProvider.to_type(event)

        {:shared, type: type}
      end

      it "set the bounded context name to the all the first module names" do
        expected_context_name = "Fixture"

        shared.type.context_name
        |> should(eq expected_context_name)
      end

      it "set the aggregate name to the module name before Event" do
        expected_aggregate_name = "Counter"

        shared.type.aggregate_name
        |> should(eq expected_aggregate_name)
      end

      it "set the event name to the last module name" do
        expected_event_name = "CounterInitialized"

        shared.type.event_name
        |> should(eq expected_event_name)
      end

      it "set the version to 1 by default" do
        expected_version = "1"

        shared.type.version
        |> should(eq expected_version)
      end
    end
  end

  describe "to_struct" do

    before do
      type = %Aggregate.Infra.EventType{
        context_name: "Fixture",
        aggregate_name: "Counter",
        event_name: "CounterInitialized",
        version: "1"
      }
      struct = Aggregate.Infra.DefaultEventNameTypeProvider.to_struct(type)

      {:shared, struct: struct}
    end

    it "creates an empty struct using the name" do
      expected_struct_module = Fixture.Counter.Event.CounterInitialized

      shared.struct.__struct__
      |> should(eq expected_struct_module)
    end
  end
end
