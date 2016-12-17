defmodule MockAgentTest do
  use ExUnit.Case

  describe "Mock Agent With Beleifs" do
    defmodule MockAgentWB do
      use EXAgent

      initialize do
        cost(:car, 10000)
        cost(:iphone, 500)
        color(:car, :red)
        color(:iphone, :black)
        is(:man, :omar)
      end

      # event_
    end

    test "it captures beleifs in initialize" do
      assert MockAgentWB.initial_beliefs ==
        [
          {:cost, {:car, 10000}},
          {:cost, {:iphone, 500}},
          {:color, {:car, :red}},
          {:color, {:iphone, :black}},
          {:is, {:man, :omar}},
        ]
    end

    test "it has a belief base with the initial beliefs" do
      ag = MockAgentWB.create(:first_agent)
      bb = MockAgentWB.belief_base(ag)
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

  describe "Mock Agent With Beleifs and Goals" do
    defmodule MockAgentWBG do
      use EXAgent

      initialize do
        cost(:car, 10000)
        money(111)
        !buy_stuff
      end
    end

    test "it captures beleifs in initial_beliefs" do
      assert MockAgentWBG.initial_beliefs ==
        [
          {:cost, {:car, 10000}},
          {:money, {111}}
        ]
    end

    test "it has a belief base with the initial beliefs" do
      ag = MockAgentWBG.create(:second_agent)
      bb = MockAgentWBG.belief_base(ag)
      assert BeliefBase.beliefs(bb) ==
        [
          {:cost, {:car, 10000}},
          {:money, {111}}
        ]
    end
  end

  describe "Mock Agent With Rules" do

    defmodule MockAgentWR do
      use EXAgent

      initialize do
        cost(:car, 10000)
        money(111)
        nice(:car)
        !buy_stuff
      end

      on(+!cost(X, Y), money(Z) && nice(X) && not want_to_buy(X) &&
         fn x, y, z -> x == y end) do

      end
    end

    test "it has rules" do
      # Add not belief
    end

  end

end
