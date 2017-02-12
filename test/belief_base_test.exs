defmodule BeliefsBaseTest do
  use ExUnit.Case

  test "it can add a beleif" do
    {res, beliefs} = BeliefBase.add_belief([], {:car, :red})

    assert res == :added
    assert beliefs == [{:car, :red}]
  end

  test "it does not add the belief twice" do
    {res, beliefs} = BeliefBase.add_belief([{:car, :red}], {:car, :red})
    assert res == :already_added
    assert beliefs == [{:car, :red}]
  end

   test "it can add 2 beleifs" do
    {_, beliefs} = BeliefBase.add_belief([], {:car, :red})
    {res, beliefs} = BeliefBase.add_belief(beliefs, {:car, :yellow})

    assert res == :added
    assert beliefs == [{:car, :red}, {:car, :yellow}]
  end

  test "it can remove a beleif" do
    {res, beliefs} = BeliefBase.remove_belief([{:car, :red}], {:car, :red})
    assert res == :removed
    assert beliefs == []
  end

  test "it does not remove a beleif that does not exist" do
    {res, beliefs} = BeliefBase.remove_belief([{:car, :red}], {:car, :red1})
    assert res == :not_found
    assert beliefs == [{:car, :red}]
  end

  test "it can remove a beleif 2" do
    {res, beliefs} = BeliefBase.remove_belief([{:car, :red}, {:is, :cool}], {:car, :red})
    assert res == :removed
    assert beliefs == [{:is, :cool}]
  end

  test "it does not remove a beleif that does not match" do
    {res, beliefs} = BeliefBase.remove_belief([{:car, {:red}}], {:car, {:green}})
    assert res == :not_found
    assert beliefs == [{:car, {:red}}]
  end

  test "it can test beleifs" do
    res = BeliefBase.test_belief([{:car, {:color, :red}}, {:is, {:cool}}], {:car, {:X, :Y}})
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

  test "it can test beleifs and return cant_unify" do
    res = BeliefBase.test_belief([{:car, {:color, :red}}, {:is, {:cool}}], {:mobile, {:X, :Y}})
    assert res == :cant_unify
  end

  test "it can test beliefs with multiple tests and a function " do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    res = BeliefBase.test_beliefs(beliefs, tests, fn x, y -> x == :color && y == :red end)
    assert res == [X: :color, Y: :red]
  end

  test "it returns error if parameters are not matched " do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    res = BeliefBase.test_beliefs(beliefs, tests, fn x, y -> x == :color1 && y == :red end)
    assert res == :cant_unify
  end

  test "it returns error if parameters are not matched 2" do
    beliefs = [{:car, {:color, :red}}, {:is, {:cool}}]
    tests = [{:car, {:X, :Y}}]
    res = BeliefBase.test_beliefs(beliefs, tests, fn x -> x == :color1 end)
    assert res == :cant_unify
  end

  test "it can test beleifs with context" do
    ctx = Context.create([{:car, {:X, :Y}}])
    res = BeliefBase.test_beliefs([{:car, {:color, :red}}, {:is, {:cool}}], ctx)
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

  test "it can test beleifs with context and function" do
    ctx = Context.create([{:car, {:X, :Y}}], fn x, _ -> x == :color end)
    res = BeliefBase.test_beliefs([{:car, {:color, :red}}, {:is, {:cool}}], ctx)
    assert res == [{:X, :color}, {:Y, :red}]
    assert res[:X] == :color
  end

end
