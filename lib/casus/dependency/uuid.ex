defmodule Casus.Dependency.UUID do
  @moduledoc """
    The behaviour specifying the Aggregate expectation concerning the UUID generator.
  """

  @type uuid :: String.t

  @callback generate() :: uuid
end
