defimpl Casus.Domain.Event, for: Fixture.Counter.Event.CounterInitialized do
  def convert_to_raw(event) do
    %{"id" => event.id, "initial_counter_value" => event.initial_counter_value}
  end

  def convert_from_raw(empty_event, data) do
    fields = [
      id: Map.get(data, "id"),
      initial_counter_value: Map.get(data, "initial_counter_value")
    ]
    struct(empty_event, fields)
  end
end

defimpl Casus.Domain.Event, for: Fixture.Counter.Event.CounterIncremented do
  def convert_to_raw(event) do
    %{"id" => event.id}
  end

  def convert_from_raw(empty_event, data) do
    fields = [
      id: Map.get(data, "id")
    ]
    struct(empty_event, fields)
  end
end
