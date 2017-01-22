defmodule MockAgentTest do
  use ExUnit.Case

  describe "Mock Agent With Beleifs" do
    defmodule MockAgentWB do
      use EXAgent

      initialize do
        +cost(:car, 10000)
        +cost(:iphone, 500)
        +color(:car, :red)
        +color(:iphone, :black)
        +is(:man, :omar)
      end

      start
    end

    test "it captures beleifs in initialize" do
      assert MockAgentWB.initial ==
        [
          %AddBelief{b: {:cost, {:car, 10000}}},
          %AddBelief{b: {:cost, {:iphone, 500}}},
          %AddBelief{b: {:color, {:car, :red}}},
          %AddBelief{b: {:color, {:iphone, :black}}},
          %AddBelief{b: {:is, {:man, :omar}}}
        ]
    end

    test "it has a belief base with the initial beliefs" do
      ag = MockAgentWB.create("ag1")
      bb = MockAgentWB.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []
    end
  end

  describe "Mock Agent With Beleifs and Goals" do
    defmodule MockAgentWBG do
      use EXAgent

      initialize do
        +cost(:car, 10000)
        +money(111)
        !buy_stuff
      end

      start
    end

    test "it captures beleifs in initial" do
      assert MockAgentWBG.initial ==
        [
          %AddBelief{b: {:cost, {:car, 10000}}},
          %AddBelief{b: {:money, {111}}},
          %AchieveGoal{g: {:buy_stuff, []}}
        ]
    end

    test "it has a belief base with the initial" do
      ag = MockAgentWBG.create("ag2")
      bb = MockAgentWBG.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []
    end
  end

end
