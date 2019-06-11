defmodule Fixture.Counter.Event.CounterInitialized do
  @moduledoc false

  @enforce_keys [:id, :initial_counter_value]
  defstruct [:id, :initial_counter_value]
end
