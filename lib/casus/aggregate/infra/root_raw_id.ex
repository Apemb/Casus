defmodule Casus.Aggregate.Infra.RootRawId do
  @moduledoc """
  A standardised representation of an aggregate Id
  """

  @type t :: %Casus.Aggregate.Infra.RootRawId {module: String.t, id: String.t}

  @enforce [:module, :id]
  defstruct [:module, :id]
end
