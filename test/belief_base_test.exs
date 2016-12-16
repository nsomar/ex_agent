defmodule BeliefsBaseTest do
  use ExUnit.Case

  test "it can add a beleif" do
    {:ok, pid} = BeliefBase.create([])

    res = BeliefBase.add_belief(pid, {:car, :red})
    assert res == [{:car, :red}]
  end

   test "it can add 2 beleifs" do
    {:ok, pid} = BeliefBase.create([])

    BeliefBase.add_belief(pid, {:car, :red})
    res = BeliefBase.add_belief(pid, {:car, :yellow})
    assert res == [{:car, :red}, {:car, :yellow}]
  end

  test "it can get the beliefs" do
    {:ok, pid} = BeliefBase.create([])

     BeliefBase.add_belief(pid, {:car, :red})
     res = BeliefBase.beliefs(pid)

    assert res == [{:car, :red}]
  end

  test "it can remove a beleif" do
    {:ok, pid} = BeliefBase.create([{:car, :red}])
    res = BeliefBase.remove_belief(pid, {:car, :red})
    assert res == []
  end

  test "it can remove a beleif 2" do
    {:ok, pid} = BeliefBase.create([{:car, :red}, {:is, :cool}])
    res = BeliefBase.remove_belief(pid, {:car, :red})
    assert res == [{:is, :cool}]
  end

  test "it can test beleifs" do
    {:ok, pid} = BeliefBase.create([{:car, {:color, :red}}, {:is, {:cool}}])
    res = BeliefBase.test_belief(pid, {:car, {:X, :Y}})
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

  test "it can test beleifs and return cant_unify" do
    {:ok, pid} = BeliefBase.create([{:car, {:color, :red}}, {:is, {:cool}}])
    res = BeliefBase.test_belief(pid, {:mobile, {:X, :Y}})
    assert res == :cant_unify
  end

  test "it can test beliefs with multiple tests and a function " do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    {:ok, pid} = BeliefBase.create(beliefs)
    res = BeliefBase.test_beliefs(pid, tests, fn x, y -> x == :color && y == :red end)
    assert res == [X: :color, Y: :red]
  end

  test "it returns error if parameters are not matched " do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    {:ok, pid} = BeliefBase.create(beliefs)
    res = BeliefBase.test_beliefs(pid, tests, fn x, y -> x == :color1 && y == :red end)
    assert res == :cant_unify
  end

  test "it returns error if parameters are not matched 2" do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    {:ok, pid} = BeliefBase.create(beliefs)
    res = BeliefBase.test_beliefs(pid, tests, fn x -> x == :color1 end)
    assert res == :cant_unify
  end

  test "it can test beleifs with context" do
    {:ok, pid} = BeliefBase.create([{:car, {:color, :red}}, {:is, {:cool}}])
    ctx = Context.create([{:car, {:X, :Y}}])
    res = BeliefBase.test_beliefs(pid, ctx)
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

  test "it can test beleifs with context and function" do
    {:ok, pid} = BeliefBase.create([{:car, {:color, :red}}, {:is, {:cool}}])
    ctx = Context.create([{:car, {:X, :Y}}], fn x, _ -> x == :color end)
    res = BeliefBase.test_beliefs(pid, ctx)
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

end
