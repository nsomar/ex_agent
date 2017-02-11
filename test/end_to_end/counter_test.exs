defmodule CounterAgent do
  use ExAgent
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
    -counter(X)
    +counter(X - 1)
    query(counter(Y))
    &print("New One " <> Integer.to_string(Y))
    !count
  end


  # recover (+!count) when counter(X) do

  # end

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
    intents = CounterAgent.create("ag") |> ExAgent.intents
    assert intents ==
    [%Intention{bindings: [], plan: nil, instructions: [
      %AddBelief{name: :counter, params: [5]},
      %AchieveGoal{name: :count, params: []}]}
    ]
  end

  test "runs 1 instruction" do
    ag = CounterAgent.create("ag")
    new_state = Reasoner.reason(ag |> ExAgent.agent_state)

    bb = CounterAgent.belief_base(ag)
    beliefs = BeliefBase.beliefs(bb)

    assert beliefs == [counter: {5}]
  end

  test "runs 2 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    bb = CounterAgent.belief_base(ag)
    beliefs = BeliefBase.beliefs(bb)

    assert beliefs == [counter: {5}]
  end

  test "runs 3 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    bb = CounterAgent.belief_base(ag)
    beliefs = BeliefBase.beliefs(bb)

    assert beliefs == [counter: {5}]
  end

  test "runs 4 instructions" do
    ag = CounterAgent.create("ag")
    bb = CounterAgent.belief_base(ag)

    Reasoner.reason_cycle(ag)
    assert BeliefBase.beliefs(bb) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert BeliefBase.beliefs(bb) == []
  end

  test "runs 5 instructions" do
    ag = CounterAgent.create("ag")
    bb = CounterAgent.belief_base(ag)

    Reasoner.reason_cycle(ag)
    assert BeliefBase.beliefs(bb) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert BeliefBase.beliefs(bb) == []

    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert BeliefBase.beliefs(bb) == [counter: {4}]
  end

  test "runs 6 instructions" do
    ag = CounterAgent.create("ag")
    bb = CounterAgent.belief_base(ag)

    Reasoner.reason_cycle(ag)
    assert BeliefBase.beliefs(bb) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert BeliefBase.beliefs(bb) == []

    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert BeliefBase.beliefs(bb) == [counter: {4}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
  end

end
