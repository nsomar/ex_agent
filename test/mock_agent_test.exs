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
          %AddBelief{b: {:cost, {:car, 10000}}, params: []},
          %AddBelief{b: {:cost, {:iphone, 500}}, params: []},
          %AddBelief{b: {:color, {:car, :red}}, params: []},
          %AddBelief{b: {:color, {:iphone, :black}}, params: []},
          %AddBelief{b: {:is, {:man, :omar}}, params: []}
        ]
    end

    test "it has a belief base with the initial beliefs" do
      ag = MockAgentWB.create("ag1")
      bb = MockAgentWB.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []
    end
  end

  describe "Mock Agent With Beleifs with vars" do
    defmodule MockAgentWVars do
      use EXAgent

      initialize do
        +cost(:car, X)
        +cost(Y, Z)
      end

      start
    end

    test "it captures beleifs in initialize" do
      assert MockAgentWVars.initial ==
        [
          %AddBelief{b: {:cost, {:car, :X}}, params: [:X]},
          %AddBelief{b: {:cost, {:Y, :Z}}, params: [:Y, :Z]},
        ]
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
          %AddBelief{b: {:cost, {:car, 10000}}, params: []},
          %AddBelief{b: {:money, {111}}, params: []},
          %AchieveGoal{g: {:buy_stuff, {}}}
        ]
    end

    test "it has a belief base with the initial" do
      ag = MockAgentWBG.create("ag2")
      bb = MockAgentWBG.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []
    end
  end

end
