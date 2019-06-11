defmodule Casus.Aggregate.Instance do
  @moduledoc false

  alias __MODULE__

  @event_store Application.get_env(:casus, :event_store)
  @uuid Application.get_env(:casus, :uuid)

  defmodule State do
    @type aggregate_id :: struct
    @type aggregate_state :: struct

    @type t :: %State {aggregate_id: aggregate_id, aggregate_state: aggregate_state}

    defstruct [:aggregate_id, :aggregate_state]
  end

  use GenServer

  def start_link(aggregate_id) do
    init_arg = %{aggregate_id: aggregate_id}

    GenServer.start_link(
      __MODULE__,
      init_arg,
      name: gen_server_name(aggregate_id)
    )
  end

  def call(aggregate_id, command) do
    GenServer.call(gen_server_name(aggregate_id), command)
  end

  defp gen_server_name(aggregate_id) do
    {:via, Registry, {Casus.Aggregate.Registry, aggregate_id}}
  end

  ## CALLBACK

  def init(%{aggregate_id: aggregate_id}) do

    aggregate_raw_id = Casus.Aggregate.Domain.Root.to_raw_id(aggregate_id)
    case @event_store.get_history(aggregate_raw_id) do
      {:ok, events} -> generate_inital_response(events, aggregate_id)
      {:error, reason} -> {:stop, reason}
    end
  end

  defp generate_inital_response(events, aggregate_id) do
    gen_server_initial_state = generate_instance_state_for_events(events, aggregate_id)
    {:ok, gen_server_initial_state}
  end

  defp generate_instance_state_for_events(events, aggregate_id) do
    aggregate_state = generate_aggregate_state_from_events(events, aggregate_id)

    %Instance.State{aggregate_id: aggregate_id, aggregate_state: aggregate_state}
  end

  defp generate_aggregate_state_from_events(events, aggregate_id) do
    initial_aggregate_state = Casus.Aggregate.Domain.Root.init_state(aggregate_id)
    Enum.map(events, &convert_infra_events_to_domain/1)
    |> Enum.reduce(initial_aggregate_state, &Casus.Aggregate.Domain.Root.apply(aggregate_id, &1, &2))
  end

  defp convert_infra_events_to_domain(%Casus.Aggregate.Infra.Event{} = infra_event) do
    infra_event.event_type
    |> Casus.Aggregate.Infra.EventNameTypeProvider.to_struct()
    |> Casus.Aggregate.Domain.Event.convert_from_raw(infra_event.event_data)
  end

  def handle_call(
        command,
        _from,
        %Instance.State{aggregate_id: aggregate_id, aggregate_state: aggregate_state} = gen_server_state
      ) do
    command_response = Casus.Aggregate.Domain.Root.handle(aggregate_id, command, aggregate_state)

    new_gen_server_state = command_response
                           |> handle_domain_command_response(gen_server_state)
                           |> generate_new_gen_server_state(gen_server_state)

    aggregate_events_result = command_response
                              |> generate_aggregate_events(aggregate_id)

    event_store_response = aggregate_events_result
                           |> generate_infra_events()
                           |> save_events()

    case event_store_response do
      :ok -> {:reply, aggregate_events_result, new_gen_server_state}
      {:error, reason} -> {:reply, {:error, {:event_store_error, reason}}, gen_server_state}
    end
  end

  defp handle_domain_command_response(
         {:ok, events},
         %Instance.State{aggregate_id: aggregate_id, aggregate_state: aggregate_state}
       ) do
    new_aggregate_state = Enum.reduce(
      events,
      aggregate_state,
      &Casus.Aggregate.Domain.Root.apply(aggregate_id, &1, &2)
    )

    {:ok, new_aggregate_state}
  end
  defp handle_domain_command_response({:error, _reason} = error, %Instance.State{}), do: error

  defp generate_new_gen_server_state({:ok, new_aggregate_state}, %Instance.State{} = gen_server_state) do
    %Instance.State{gen_server_state | aggregate_state: new_aggregate_state}
  end
  defp generate_new_gen_server_state({:error, _reason}, %Instance.State{} = gen_server_state), do: gen_server_state

  defp generate_aggregate_events({:ok, domain_events} = _command_response, aggregate_id) do
    aggregate_events = Enum.map(
      domain_events,
      fn event ->
        %Casus.Aggregate.Event{
          id: @uuid.generate(),
          aggregate_id: aggregate_id,
          event: event,
          timestamp: Casus.Aggregate.Infra.TimeStamper.now()
        }
      end
    )
    {:ok, aggregate_events}
  end
  defp generate_aggregate_events({:error, reason} = _command_response, _aggregate_id), do: {:error, reason}

  defp generate_infra_events({:ok, aggregate_events}) do
    infra_events = Enum.map(
      aggregate_events,
      fn aggregate_event ->
        raw_event_data = Casus.Aggregate.Domain.Event.convert_to_raw(aggregate_event.event)
        event_type = Casus.Aggregate.Infra.EventNameTypeProvider.to_type(aggregate_event.event)
        aggregate_id = Casus.Aggregate.Domain.Root.to_raw_id(aggregate_event.aggregate_id)

        %Casus.Aggregate.Infra.Event{
          id: aggregate_event.id,
          aggregate_id: aggregate_id,
          event_type: event_type,
          event_data: raw_event_data,
          event_timestamp: aggregate_event.timestamp
        }
      end
    )
    {:ok, infra_events}
  end
  defp generate_infra_events({:error, reason}), do: {:error, reason}

  defp save_events({:ok, infra_events}) do
    @event_store.save(infra_events)
  end
  defp save_events({:error, _reason}), do: :ok

  def handle_cast(_msg, state) do
    {:noreply, state}
  end
end