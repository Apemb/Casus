defmodule AggregateSpec do
  @moduledoc false

  use ESpec
  import Ersatz.Matchers.ESpec

  alias Fixture.Counter
  alias Casus.Aggregate

  before do
    Ersatz.set_ersatz_global()
  end

  finally do
    Ersatz.clear_mock_calls(&Mock.UUID.generate/0)
    Ersatz.clear_mock_calls(&Mock.EventStore.get_history/1)
    Ersatz.clear_mock_calls(&Mock.EventStore.save/1)
    Ersatz.clear_mock_calls(&Mock.TimeStamper.now/0)

    Aggregate.list_running_instances()
    |> Enum.each(&Aggregate.stop_instance/1)
  end

  describe "execute" do

    before do
      id = "123"
      aggregate = %Fixture.Counter{id: id}
      {:ok, timestamp, _} = DateTime.from_iso8601("1969-07-21T03:56:00.000000Z")
      uuid = "uuid-mock-value"
      Ersatz.set_mock_implementation(&Mock.EventStore.save/1, fn _ -> :ok end)
      Ersatz.set_mock_implementation(&Mock.EventStore.get_history/1, fn _ -> {:ok, []} end)

      Ersatz.set_mock_implementation(&Mock.UUID.generate/0, fn -> uuid end)
      Ersatz.set_mock_implementation(&Mock.TimeStamper.now/0, fn -> timestamp end)

      {:shared, id: id, timestamp: timestamp, uuid: uuid, aggregate: aggregate}
    end

    context "first time calling this specific aggregate" do

      before do
        command = %Counter.Command.Initialize{id: shared.id, initial_counter_value: 0}
        command_response = Aggregate.execute(shared.aggregate, command)

        Ersatz.set_mock_implementation(&Mock.EventStore.get_history/1, fn _ -> {:ok, []} end)

        {:shared, command: command, command_response: command_response}
      end

      it "starts a aggregate module instance" do
        Aggregate.list_running_instances()
        |> should(contain_exactly [shared.aggregate])
      end

      it "loads past events once" do
        aggregate_id = Casus.Domain.Root.to_raw_id(shared.aggregate)

        (&Mock.EventStore.get_history/1)
        |> should(have_been_called_with(exactly: [{aggregate_id}]))
      end

      it "returns a list of aggregate events with events returned from the aggregate domain module" do
        initial_state = Counter.init_state()
        {:ok, domain_events} = Counter.handle(shared.command, initial_state)

        events = Enum.map(
          domain_events,
          fn event -> %Aggregate.Event{
                        id: shared.uuid,
                        aggregate_id: shared.aggregate,
                        event: event,
                        timestamp: shared.timestamp
                      }
          end
        )
        expected_result = {:ok, events}

        shared.command_response
        |> should(eq expected_result)
      end
    end

    context "calling twice the same aggregate" do

      before do
        command = %Counter.Command.Initialize{id: shared.id, initial_counter_value: 0}
        first_command_response = Aggregate.execute(shared.aggregate, command)
        second_command_response = Aggregate.execute(shared.aggregate, command)

        {
          :shared,
          command: command,
          first_command_response: first_command_response,
          second_command_response: second_command_response
        }
      end

      it "starts only one aggregate module instance" do
        Aggregate.list_running_instances()
        |> should(contain_exactly [shared.aggregate])
      end

      it "returns the first result from the handle function of the aggregate domain module" do
        initial_state = Counter.init_state()
        {:ok, first_domain_events} = Counter.handle(shared.command, initial_state)
        first_events = convert_to_aggregate_events(first_domain_events, shared.aggregate, shared.uuid, shared.timestamp)
        first_expected_result = {:ok, first_events}

        shared.first_command_response
        |> should(eq first_expected_result)
      end

      it "returns the second result taking the resulting state after the first command (second result is an error)" do
        initial_state = Counter.init_state()
        {:ok, events} = Counter.handle(shared.command, initial_state)
        second_state = Enum.reduce(events, initial_state, &Counter.apply/2)
        second_expected_result = Counter.handle(shared.command, second_state)

        shared.second_command_response
        |> should(eq second_expected_result)
      end
    end

    context "saving to event store succeeds" do

      before do
        uuid = "uuid-mock-value"
        Ersatz.set_mock_implementation(&Mock.UUID.generate/0, fn -> uuid end, times: 1)
        Ersatz.set_mock_implementation(&Mock.UUID.generate/0, fn -> "not-the-first-uuid" end, times: 1)

        command = %Counter.Command.Initialize{id: shared.id, initial_counter_value: 0}
        command_response = Aggregate.execute(shared.aggregate, command)

        initial_state = Counter.init_state()
        aggregate_id = Casus.Domain.Root.to_raw_id(shared.aggregate)
        {:ok, domain_events} = Counter.handle(command, initial_state)

        aggregate_events = convert_to_aggregate_events(domain_events, shared.aggregate, uuid, shared.timestamp)
        infra_events = convert_to_infra_events(domain_events, aggregate_id, uuid, shared.timestamp)

        {
          :shared,
          command: command,
          command_response: command_response,
          uuid: uuid,
          aggregate_events: aggregate_events,
          infra_events: infra_events
        }
      end

      it "returns the result from the handle function of the aggregate domain module" do
        expected_result = {:ok, shared.aggregate_events}

        shared.command_response
        |> should(eq expected_result)
      end

      it "saves the events once in the event store" do
        (&Mock.EventStore.save/1)
        |> should(have_been_called_with(exactly: [{shared.infra_events}]))
      end

      it "updates the internal state of instance" do
        command = %Counter.Command.Increment{id: shared.id}
        command_response = Aggregate.execute(shared.aggregate, command)

        {:ok, [produced_event]} = command_response
        produced_event.event
        |> should(eq %Counter.Event.CounterIncremented{id: shared.id})
      end
    end

    context "saving to event store fails" do

      before do
        database_error = :database_fails
        Ersatz.set_mock_implementation(&Mock.EventStore.save/1, fn _ -> {:error, database_error} end)

        command = %Counter.Command.Initialize{id: shared.id, initial_counter_value: 0}
        command_response = Aggregate.execute(shared.aggregate, command)

        {:shared, command: command, command_response: command_response, database_error: database_error}
      end

      it "returns the database error" do
        shared.command_response
        |> should(eq {:error, {:event_store_error, shared.database_error}})
      end

      it "tries to save the events once in the event store" do
        (&Mock.EventStore.save/1)
        |> should(have_been_called(times: 1))
      end

      it "does not update the internal state of instance" do
        command = %Counter.Command.Increment{id: shared.id}
        command_response = Aggregate.execute(shared.aggregate, command)

        command_response
        |> should(eq {:error, :counter_should_be_initiliazed})
      end
    end

    context "first time calling this specific aggregate when it already has events saved" do

      before do
        past_domain_events = [
          %Counter.Event.CounterInitialized{id: shared.id, initial_counter_value: 0},
          %Counter.Event.CounterIncremented{id: shared.id},
          %Counter.Event.CounterIncremented{id: shared.id},
          %Counter.Event.CounterIncremented{id: shared.id},
        ]
        aggregate_instance_spec = Casus.Domain.Root.to_raw_id(shared.aggregate)
        past_events = Enum.map(
          past_domain_events,
          fn event -> %Casus.Infra.Event {
                        id: "xxx-xxx-xxx-xxx",
                        aggregate_id: aggregate_instance_spec,
                        event_type: Casus.Infra.EventNameTypeProvider.to_type(event),
                        event_data: Casus.Domain.Event.convert_to_raw(event),
                        event_timestamp: shared.timestamp
                      }
          end
        )

        Ersatz.set_mock_implementation(&Mock.EventStore.get_history/1, fn _ -> {:ok, past_events} end)

        command = %Counter.Command.CommandThatFailsIfCounterOverValue{id: shared.id, max_value: 2}
        command_response = Aggregate.execute(shared.aggregate, command)

        {:shared, command: command, command_response: command_response, past_domain_events: past_domain_events}
      end

      it "starts a aggregate module instance" do
        Aggregate.list_running_instances()
        |> should(contain_exactly [shared.aggregate])
      end

      it "loads past events once" do
        aggregate_id = Casus.Domain.Root.to_raw_id(shared.aggregate)

        (&Mock.EventStore.get_history/1)
        |> should(have_been_called_with(exactly: [{aggregate_id}]))
      end

      it "returns the result from the handle function of the aggregate domain module" do
        expected_result = {:error, :counter_over_max_value}

        shared.command_response
        |> should(eq expected_result)
      end
    end

    context "first time calling this aggregate when loading events fails" do

      before do
        error_message = "database somehow failed"
        Ersatz.set_mock_implementation(&Mock.EventStore.get_history/1, fn _ -> {:error, error_message} end)

        command = %Counter.Command.CommandThatFailsIfCounterOverValue{id: shared.id, max_value: 2}
        command_response = Aggregate.execute(shared.aggregate, command)

        {:shared, error_message: error_message, command_response: command_response}
      end

      it "does not starts a aggregate module instance" do
        Aggregate.list_running_instances()
        |> should(be_empty())
      end

      it "loads past events once" do
        aggregate_id = Casus.Domain.Root.to_raw_id(shared.aggregate)

        (&Mock.EventStore.get_history/1)
        |> should(have_been_called_with(exactly: [{aggregate_id}]))
      end

      it "returns the error from the failed loading" do
        expected_result = {:error, shared.error_message}

        shared.command_response
        |> should(eq expected_result)
      end
    end
  end

  defp convert_to_aggregate_events(domain_events, aggregate_id, fixed_id, fixed_timestamp) do
    Enum.map(
      domain_events,
      fn event ->
        %Aggregate.Event{
          id: fixed_id,
          aggregate_id: aggregate_id,
          event: event,
          timestamp: fixed_timestamp
        }
      end
    )
  end

  defp convert_to_infra_events(domain_events, aggregate_id, fixed_id, fixed_timestamp) do
    Enum.map(
      domain_events,
      fn event ->
        event_type = Casus.Infra.EventNameTypeProvider.to_type(event)
        event_data = Casus.Domain.Event.convert_to_raw(event)
        %Casus.Infra.Event{
          id: fixed_id,
          aggregate_id: aggregate_id,
          event_type: event_type,
          event_data: event_data,
          event_timestamp: fixed_timestamp
        }
      end
    )
  end
end
