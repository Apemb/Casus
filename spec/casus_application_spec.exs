defmodule CasusApplicationSpec do
  @moduledoc false

  use ESpec

  describe "start" do

    it "starts a registry named Casus.Aggregate.Registry" do
      Supervisor.which_children(Casus.RootSupervisor)
      |> Enum.filter(&(Casus.Aggregate.Registry == elem(&1, 0)))
      |> should(match_pattern [{Casus.Aggregate.Registry, _, :supervisor, [Registry]}])
    end

    it "starts a dynamic supervisor named Casus.Aggregate.DynamicSupervisor" do
      Supervisor.which_children(Casus.RootSupervisor)
      |> Enum.filter(&(Casus.Aggregate.DynamicSupervisor == elem(&1, 0)))
      |> should(match_pattern [{Casus.Aggregate.DynamicSupervisor, _, :supervisor, [Casus.Aggregate.DynamicSupervisor]}])
    end
  end
end
