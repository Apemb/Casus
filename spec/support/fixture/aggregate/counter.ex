defmodule Fixture.Counter do
  @moduledoc false

  alias __MODULE__

  @enforce_keys [:id]
  defstruct id: nil

  defdelegate init_state(), to: Counter.State
  defdelegate handle(command, state), to: Counter.Command
  defdelegate apply(event, state), to: Counter.State

end
