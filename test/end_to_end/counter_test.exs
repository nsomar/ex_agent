defmodule CounterAgent do
  use ExAgent.Mod
  # use Protocols.only(:asdsa, :aaaa)

  initialize do
    +counter(5)
    !count
  end

  rule (+!count) when counter(0) do
    &print("DONE")
  end

  rule (+!count) when counter(X) do
    &print("Current " <> Integer.to_string(X))
    -+counter(X - 1)
    query(counter(Y))
    &print("New One " <> Integer.to_string(Y))
    !count
  end

  start
end

defmodule CounterAgentTest do
  use ExUnit.Case

  test "it parses the plans" do
    rules = CounterAgent.plan_rules
    assert rules |> Enum.count == 2
  end

  test "it parses the initializer" do
    initial = CounterAgent.initial
    assert initial ==
    [%AddBelief{name: :counter, params: [5]},
     %AchieveGoal{name: :count, params: []}]
  end

  test "it gets the initial intents" do
    intents = CounterAgent.create("ag") |> ExAgent.Mod.intents
    assert intents ==
    [%Intention{executions: [%IntentionExecution{bindings: [], event: :initialize, plan: nil, instructions: [%AddBelief{name: :counter, params: [5]}, %AchieveGoal{name: :count, params: []}]}]}]
  end

  test "runs 1 instruction" do
    ag = CounterAgent.create("ag")
    Reasoner.reason_cycle(ag)
    beliefs = ExAgent.Mod.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 2 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.Mod.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 3 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.Mod.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 4 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.Mod.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]
  end

  test "runs 5 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.Mod.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]
  end

  test "runs 6 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.Mod.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
  end

  test "runs 7 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.Mod.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.Mod.agent_state(ag)| plan_rules: []}
    assert ExAgent.Mod.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    assert ExAgent.Mod.beliefs(ag) == [counter: {3}]
  end

  test "agent loop" do
    ag = CounterAgent.create("ag")
    ExAgent.Mod.run_loop(ag)
    # IO.inspect "Sss"
    Process.sleep(100)
    assert ExAgent.Mod.agent_state(ag).events == []
    assert ExAgent.Mod.agent_state(ag).intents == []
  end

end
