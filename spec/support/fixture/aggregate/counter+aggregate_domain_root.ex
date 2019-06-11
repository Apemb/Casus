defimpl Casus.Aggregate.Domain.Root, for: Fixture.Counter do

  def init_state(_aggregate_id), do: Fixture.Counter.init_state()
  def handle(_aggregate_id, command, state), do: Fixture.Counter.handle(command, state)
  def apply(_aggregate_id, event, state), do: Fixture.Counter.apply(event, state)

  def to_string(aggregate_id), do: "Counter-#{aggregate_id.id}"
  def to_raw_id(aggregate_id), do: %Casus.Aggregate.Infra.RootRawId{module: "Counter", id: aggregate_id.id}
end
