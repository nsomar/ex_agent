defmodule ExecutorTestAgent do
  use EXAgent

  initialize do
    +counter(0)
    +counter(X)
  end

  start
end

defmodule ExecutorTest do
  use ExUnit.Case

  describe "Add belief" do
    test "it adds a belief" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      instruction = ExecutorTestAgent.initial |> Enum.at(0)
      Executor.execute(instruction, ag, []) |> IO.inspect
      assert BeliefBase.beliefs(bb) == [counter: {0}]
    end

    test "it adds a belief with binding" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      instruction = ExecutorTestAgent.initial |> Enum.at(1)
      Executor.execute(instruction, ag, [X: 20])
      assert BeliefBase.beliefs(bb) == [counter: {20}]
    end

  end

end
