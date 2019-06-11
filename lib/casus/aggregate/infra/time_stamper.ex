defmodule Casus.Aggregate.Infra.TimeStamper do
  @moduledoc """
  Module to provide a mechanism to generate timestamps.
  """

  defmodule Behaviour do
    @moduledoc """
    Behaviour to implement to override default time stamper.
    """

    @doc """
    Generate a utc based datetime object for now
    """
    @callback now() :: DateTime.t()
  end

  @behaviour Casus.Aggregate.Infra.TimeStamper.Behaviour

  @impl Casus.Aggregate.Infra.TimeStamper.Behaviour
  def now(), do: time_stamper().now()

  def time_stamper do
    Application.get_env(:casus, :time_stamper, Casus.Aggregate.Infra.TimeStamper.Default)
  end

  defmodule Default do
    @moduledoc false
    @behaviour Casus.Aggregate.Infra.TimeStamper.Behaviour

    @impl Casus.Aggregate.Infra.TimeStamper.Behaviour
    def now(), do: DateTime.utc_now()
  end
end
