defmodule ExagentTest do
  use ExUnit.Case
  doctest ExAgent

  test "can get the beleif base" do
    agent = ExAgent.create(:"name1")
    val = ExAgent.belief_base(agent)
    assert val != nil
  end

  test "can get the beleifs from belief base" do
    agent = ExAgent.create(:"name2")
    bb = ExAgent.belief_base(agent)
    BeliefBase.add_belief(bb, {:abcd})

    assert BeliefBase.beliefs(bb) == [{:abcd}]
  end

end
