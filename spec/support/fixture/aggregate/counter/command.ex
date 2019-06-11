defmodule Fixture.Counter.Command do
  @moduledoc false

  alias Fixture.Counter

  def handle(%Counter.Command.Initialize{} = command, %Counter.State{id: nil} = _state) do
    {
      :ok,
      [
        %Counter.Event.CounterInitialized{
          id: command.id,
          initial_counter_value: command.initial_counter_value
        }
      ]
    }
  end

  def handle(%Counter.Command.Initialize{} = _command, %Counter.State{} = _state) do
    {:error, :counter_already_initialized}
  end

  def handle(%Counter.Command.Increment{} = _command, %Counter.State{id: nil} = _state) do
    {:error, :counter_should_be_initiliazed}
  end

  def handle(%Counter.Command.Increment{} = _command, %Counter.State{} = state) do
    {:ok, [%Counter.Event.CounterIncremented{id: state.id}]}
  end

  def handle(%Counter.Command.CommandThatFailsIfCounterOverValue{} = _command, %Counter.State{id: nil} = _state) do
    {:error, :counter_should_be_initiliazed}
  end

  def handle(%Counter.Command.CommandThatFailsIfCounterOverValue{} = command, %Counter.State{} = state) do
    if state.count >= command.max_value do
      {:error, :counter_over_max_value}
    else
      {:ok, []}
    end
  end

  def handle(_, _) do
    {:error, :wrong_commmand_or_falty_state}
  end
end
