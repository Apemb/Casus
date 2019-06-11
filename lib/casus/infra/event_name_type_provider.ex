defmodule Casus.Infra.EventNameTypeProvider do
  @moduledoc """
  Module to provide the conversion between the event struct and a corresponding string type.
  """

  @type event :: struct
  @type type :: Casus.Infra.EventType.t

  @doc """
  Type of the given Elixir struct as a string
  """
  @callback to_type(event) :: type

  @doc """
  Convert the given type string to an Elixir struct
  """
  @callback to_struct(type) :: event

  @doc false
  @spec to_type(event) :: type
  def to_type(struct), do: type_provider().to_type(struct)

  @doc false
  @spec to_struct(type) :: event
  def to_struct(type), do: type_provider().to_struct(type)

  @doc false
  def type_provider do
    Application.get_env(:casus, :type_provider, Casus.Infra.DefaultEventNameTypeProvider)
  end
end
