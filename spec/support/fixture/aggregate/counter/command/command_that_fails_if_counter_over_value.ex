defmodule Fixture.Counter.Command.CommandThatFailsIfCounterOverValue do
  @moduledoc false

  @enforce_keys [:id, :max_value]
  defstruct [:id, :max_value]
end
