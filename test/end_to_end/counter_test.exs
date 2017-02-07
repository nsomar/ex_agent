defmodule CounterAgent do
  use EXAgent

  initialize do
    +counter(5)
    !count
  end

  rule (+!count) when counter(0) do
    &print("DONE")
  end

  rule (+!count) when counter(X) do
    &print("Current " <> X)
    -counter(X)
    +counter(X - 1)
    !count
    &print(X + 1, Y, Z * 2)
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

  test "runtime" do
    ag = CounterAgent.create("ag")
    initial = CounterAgent.initial
    inst = initial |> hd

    new_binding = Executor.execute(inst, ag, [])

    bb = CounterAgent.belief_base(ag)
    beliefs = BeliefBase.beliefs(bb)

    assert beliefs == [counter: {5}]

    inst = initial |> Enum.at(1)
    Reasoner.reason(ag, inst, new_binding)
  end

end
