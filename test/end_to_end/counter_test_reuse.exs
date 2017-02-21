defmodule CounterReuse do
  use ExAgent.Core

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

defmodule CounterReuseAgent do
  use ExAgent

  responsibilities do
    CounterReuse
  end

  initialize do
    +counter(5)
    !count
  end

  start
end

defmodule CounterReuseAgentTest do
  use ExUnit.Case

  test "it parses the plans" do
    ag = CounterReuseAgent.create("ag")
    rules = ExAgent.plan_rules(ag)
    assert rules |> Enum.count == 2
  end

  test "it parses the initializer" do
    initial = CounterReuseAgent.initial
    assert initial ==
    [%AddBelief{name: :counter, params: [5]},
     %AchieveGoal{name: :count, params: []}]
  end

  test "it gets the initial intents" do
    intents = CounterReuseAgent.create("ag") |> ExAgent.intents
    assert intents ==
    [%Intention{executions: [%IntentionExecution{bindings: [], event: :initialize, plan: nil, instructions: [%AddBelief{name: :counter, params: [5]}, %AchieveGoal{name: :count, params: []}]}]}]
  end

  test "runs 1 instruction" do
    ag = CounterReuseAgent.create("ag")
    Reasoner.reason_cycle(ag)
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 2 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 3 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 4 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]
  end

  test "runs 5 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]
  end

  test "runs 6 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
  end

  test "runs 7 instructions" do
    ag = CounterReuseAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {3}]
  end

  test "agent loop" do
    ag = CounterReuseAgent.create("ag")
    ExAgent.run_loop(ag)
    # IO.inspect "Sss"
    Process.sleep(100)
    assert ExAgent.agent_state(ag).events == []
    assert ExAgent.agent_state(ag).intents == []
  end

end

