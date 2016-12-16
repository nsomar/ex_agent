defmodule MockAgent do
  use EXAgent

  initial_beliefs do
    cost(:car, 10000)
    cost(:iphone, 500)
    color(:car, :red)
    color(:iphone, :black)
    is(:man, :omar)
  end

  # event_
end

defmodule MockAgentTest do
  use ExUnit.Case

  test "it captures beleifs in initial_beliefs" do
    assert MockAgent.initial_beliefs ==
      [
        {:cost, {:car, 10000}},
        {:cost, {:iphone, 500}},
        {:color, {:car, :red}},
        {:color, {:iphone, :black}},
        {:is, {:man, :omar}},
      ]
  end

  test "it has a belief base with the initial beliefs" do
    ag = MockAgent.create(:first_agent)
    bb = MockAgent.belief_base(ag)
    assert BeliefBase.beliefs(bb) ==
      [
        {:cost, {:car, 10000}},
        {:cost, {:iphone, 500}},
        {:color, {:car, :red}},
        {:color, {:iphone, :black}},
        {:is, {:man, :omar}},
      ]
  end

end
