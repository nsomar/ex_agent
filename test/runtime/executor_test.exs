defmodule ExecutorTestAgent do
  use ExAgent

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
      instruction = ExecutorTestAgent.initial |> Enum.at(0)
      {{_, beliefs}, bindings} = Executor.execute(instruction, [], [])

      assert beliefs == [counter: {0}]
      assert bindings == []
    end

    test "it adds a belief with binding" do
      instruction = ExecutorTestAgent.initial |> Enum.at(1)
      {beliefs, bindings} = Executor.execute(instruction, [], [X: 20])
      assert beliefs == {:added, [counter: {20}]}
      assert bindings == [X: 20]
    end

    test "it removes a belief" do
      instruction = ExecutorTestAgent.initial |> Enum.at(2)
      {beliefs, bindings} = Executor.execute(instruction, [counter: {0}], [X: 20])

      assert beliefs == []
      assert bindings == [X: 20]
    end

    test "it removes a belief with binding" do
      instruction = ExecutorTestAgent.initial |> Enum.at(3)
      {beliefs, bindings} = Executor.execute(instruction, [counter: {10}], [X: 10])

      assert beliefs == []
      assert bindings == [X: 10]
    end

    test "it add and remove multiple beliefs" do
      instruction = ExecutorTestAgent.initial |> Enum.at(0)
      {{:added, beliefs}, bindings} = Executor.execute(instruction, [], [X: 10])

      assert beliefs == [counter: {0}]
      assert bindings == [X: 10]

      instruction = ExecutorTestAgent.initial |> Enum.at(1)
      {{:added, beliefs}, bindings} = Executor.execute(instruction, beliefs, [X: 20])

      assert beliefs == [counter: {0}, counter: {20}]
      assert bindings == [X: 20]

      instruction = ExecutorTestAgent.initial |> Enum.at(2)
      {beliefs, bindings} = Executor.execute(instruction, beliefs, [X: 30])

      assert beliefs == [counter: {20}]
      assert bindings == [X: 30]

      instruction = ExecutorTestAgent.initial |> Enum.at(3)
      {beliefs, bindings} = Executor.execute(instruction, beliefs, [X: 40])

      assert beliefs == [counter: {20}]
      assert bindings == [X: 40]
    end

  end

  describe "Query a belief" do

    test "it queries a belief" do
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      {_, bindings} = Executor.execute(instruction, [{:counter, {1}}], [])
      assert bindings == []
    end

    test "it queries a belief without binding" do
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      {_, res} = Executor.execute(instruction, [{:counter, {1}}], [X: 123])
      assert res == [X: 123]
    end

    test "it queries a belief with binding" do
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      {_, res} = Executor.execute(instruction, [{:counter, {10}}], [X: 123])
      assert res == [X: 123, Y: 10]
    end

    test "it queries a belief with a bound var" do
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      {_, res} = Executor.execute(instruction, [{:counter, {123}}], [Y: 123])
      assert res == [Y: 123]
    end

    test "it queries a belief that does not exist" do
      instruction = ExecutorTestAgent.initial |> Enum.at(4)
      {_, res} = Executor.execute(instruction, [{:counter, {123}}], [])
      assert res == :stop
    end

    test "it queries a belief that does not exist with vars" do
      instruction = ExecutorTestAgent.initial |> Enum.at(5)
      {_, res} = Executor.execute(instruction, [{:counter, {123}}], [Y: 2])
      assert res == :stop

      # instruction = ExecutorTestAgent.initial |> Enum.at(6) |> IO.inspect
    end

  end

end
