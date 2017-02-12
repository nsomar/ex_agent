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
    intents = CounterAgent.create("ag") |> ExAgent.intents
    assert intents ==
    [%Intention{bindings: [], plan: nil, instructions: [
      %AddBelief{name: :counter, params: [5]},
      %AchieveGoal{name: :count, params: []}]}
    ]
  end

  test "runs 1 instruction" do
    ag = CounterAgent.create("ag")
    Reasoner.reason_cycle(ag)
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 2 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    %{ExAgent.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 3 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    beliefs = ExAgent.beliefs(ag)

    assert beliefs == [counter: {5}]
  end

  test "runs 4 instructions" do
    ag = CounterAgent.create("ag")

    Reasoner.reason_cycle(ag)
    assert ExAgent.beliefs(ag) == [counter: {5}]

    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)
    Reasoner.reason_cycle(ag)

    %{ExAgent.agent_state(ag)| plan_rules: []}
    assert ExAgent.beliefs(ag) == [counter: {4}]
  end

  test "runs 5 instructions" do
    ag = CounterAgent.create("ag")

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
    ag = CounterAgent.create("ag")

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
    ag = CounterAgent.create("ag")

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
    ag = CounterAgent.create("ag")
    # ExAgent.run_loop(ag)
    # IO.inspect "Sss"
    # Process.sleep(10000)
  end

end
