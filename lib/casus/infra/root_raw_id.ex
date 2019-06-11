defmodule Casus.Infra.RootRawId do
  @moduledoc """
  A standardised representation of an aggregate Id
  """

  @type t :: %Casus.Infra.RootRawId {module: String.t, id: String.t}

  @enforce [:module, :id]
  defstruct [:module, :id]
end
