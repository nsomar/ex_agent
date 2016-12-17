defmodule ExagentTest do
  use ExUnit.Case
  doctest EXAgent

  test "can get the beleif base" do
    agent = EXAgent.create()
    val = EXAgent.belief_base(agent)
    assert val != nil
  end

  test "can get the beleifs from belief base" do
    agent = EXAgent.create()
    bb = EXAgent.belief_base(agent)
    BeliefBase.add_belief(bb, {:abcd})

    assert BeliefBase.beliefs(bb) == [{:abcd}]
  end

end
