defmodule Fixture.Counter.State do
  @moduledoc false

  alias Fixture.Counter
  alias __MODULE__

  @type t :: %State{id: String.t, count: integer}
  defstruct id: nil,
            count: nil

  def init_state() do
    %State{}
  end

  def apply(%Counter.Event.CounterInitialized{} = event, %State{} = state) do
    %State{state | id: event.id, count: event.initial_counter_value}
  end

  def apply(%Counter.Event.CounterIncremented{} = _event, %State{} = state) do
    %State{state | count: state.count + 1}
  end

  def apply(_, _) do
    {:error, :wrong_event}
  end
end
