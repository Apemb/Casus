defmodule Casus.Aggregate do
  @moduledoc """
    The Casus.Aggregate module is the instances orchestrator implementation.

    Dependencies needed :
      -  Casus.Dependency.EventStore @behaviour accessible in env variable :event_store
      -  Casus.Dependency.UUID @behaviour accessible in env variable :uuid
  """

  @event_store Application.get_env(:casus, :event_store)

  def initialize() do
    @event_store.initialize()
  end

  def list_running_instances() do
    Supervisor.which_children(Casus.Aggregate.DynamicSupervisor)
    |> Enum.map(fn {_, pid, _, _} -> List.first(Registry.keys(Casus.Aggregate.Registry, pid)) end)
  end

  def stop_instance(aggregate_id) do
    pid_to_stop = Registry.lookup(Casus.Aggregate.Registry, aggregate_id)
                  |> List.first()
                  |> elem(0)

    DynamicSupervisor.terminate_child(Casus.Aggregate.DynamicSupervisor, pid_to_stop)
  end

  def execute(aggregate_id, command) do
    module_not_started_yet = Registry.lookup(Casus.Aggregate.Registry, aggregate_id)
                             |> Enum.empty?()

    init_instance_if_needed(module_not_started_yet, aggregate_id)
    |> call_instance(aggregate_id, command)
  end

  defp init_instance_if_needed(true = _module_should_be_started, aggregate_id) do
    Casus.Aggregate.DynamicSupervisor.start_instance(aggregate_id)
  end
  defp init_instance_if_needed(false = _module_should_be_started, _aggregate_id) do
    {:ok, "no init needed"}
  end

  defp call_instance({:ok, _} = _reponse_from_launch, aggregate_id, command) do
    Casus.Aggregate.Instance.call(aggregate_id, command)
  end
  defp call_instance({:error, reason} = _reponse_from_launch, _aggregate_id, _command), do: {:error, reason}
end
