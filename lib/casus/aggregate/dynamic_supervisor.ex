defmodule Casus.Aggregate.DynamicSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(arg) do
    DynamicSupervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def init(_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_instance(aggregate_id) do
    DynamicSupervisor.start_child(
      __MODULE__,
      {Casus.Aggregate.Instance, aggregate_id}
    )
  end
end
