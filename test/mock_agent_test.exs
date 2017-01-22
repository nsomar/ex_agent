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

      # event_
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
      ag = MockAgentWB.agent
      bb = MockAgentWB.a

      # assert BeliefBase.beliefs(bb) == []
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
      ag = MockAgentWBG.agent
      bb = MockAgentWBG.belief_base
      assert BeliefBase.beliefs(bb) == []
    end
  end

  describe "Mock Agent With Rules" do

    defmodule MockAgentWR do
      use EXAgent

      initialize do
        +cost(:car, 10000)
        +money(111)
        +nice(:car)
        !buy_stuff
      end

      on(+cost(X, Y), money(Z) && nice(X) && not want_to_buy(X) &&
         fn x, y, z -> x == y end) do

      end
    end

    test "it has rules" do
      # Add not belief
    end

  end

end
