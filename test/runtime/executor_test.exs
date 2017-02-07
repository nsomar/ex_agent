defmodule ExecutorTestAgent do
  use EXAgent

  initialize do
    +counter(0)
    +counter(X)
    -counter(0)
    -counter(X)
    query(counter(1))
    query(counter(Y))
    &print(Word1 <> String.upcase(Word2))
  end

  start
end

defmodule ExecutorTest do
  use ExUnit.Case

  describe "Add and Remove a belief" do
    test "it adds a belief" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      instruction = ExecutorTestAgent.initial |> Enum.at(0)
      Executor.execute(instruction, ag, [])
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

    test "it removes a belief" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      BeliefBase.add_belief(bb, {:counter, {0}})
      assert BeliefBase.beliefs(bb) == [counter: {0}]

      instruction = ExecutorTestAgent.initial |> Enum.at(2)
      Executor.execute(instruction, ag, [X: 20])
      assert BeliefBase.beliefs(bb) == []
    end

    test "it removes a belief with binding" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      BeliefBase.add_belief(bb, {:counter, {10}})
      assert BeliefBase.beliefs(bb) == [counter: {10}]

      instruction = ExecutorTestAgent.initial |> Enum.at(3)
      Executor.execute(instruction, ag, [X: 10])
      assert BeliefBase.beliefs(bb) == []
    end

    test "it add and remove multiple beliefs" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      instruction = ExecutorTestAgent.initial |> Enum.at(0)
      Executor.execute(instruction, ag, [X: 10])
      assert BeliefBase.beliefs(bb) == [counter: {0}]

      instruction = ExecutorTestAgent.initial |> Enum.at(1)
      Executor.execute(instruction, ag, [X: 20])
      assert BeliefBase.beliefs(bb) == [counter: {0}, counter: {20}]

      instruction = ExecutorTestAgent.initial |> Enum.at(2)
      Executor.execute(instruction, ag, [X: 30])
      assert BeliefBase.beliefs(bb) == [counter: {20}]

      instruction = ExecutorTestAgent.initial |> Enum.at(3)
      Executor.execute(instruction, ag, [X: 40])
      assert BeliefBase.beliefs(bb) == [counter: {20}]
    end

  end

  describe "Query a belief" do


    test "it queries a belief" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {1}})
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      res = Executor.execute(instruction, ag, [])
      assert res == []
    end

    test "it queries a belief without binding" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {1}})
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      res = Executor.execute(instruction, ag, [X: 123])
      assert res == [X: 123]
    end

    test "it queries a belief with binding" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {10}})
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      res = Executor.execute(instruction, ag, [X: 123])
      assert res == [X: 123, Y: 10]
    end

    test "it queries a belief with a bound var" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {123}})
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      res = Executor.execute(instruction, ag, [Y: 123])
      assert res == [Y: 123]
    end

    test "it queries a belief that does not exist" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {123}})
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      res = Executor.execute(instruction, ag, [])
      assert res == :stop
    end

    test "it queries a belief that does not exist with vars" do
      ag = ExecutorTestAgent.create("agent1")
      bb = ExecutorTestAgent.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []

      BeliefBase.add_belief(bb, {:counter, {123}})
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      res = Executor.execute(instruction, ag, [Y: 2])
      assert res == :stop

      # instruction = ExecutorTestAgent.initial |> Enum.at(6) |> IO.inspect
    end

  end

end
