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
          %AddBelief{name: :cost, params: [:car, 10000]},
          %AddBelief{name: :cost, params: [:iphone, 500]},
          %AddBelief{name: :color, params: [:car, :red]},
          %AddBelief{name: :color, params: [:iphone, :black]},
          %AddBelief{name: :is, params: [:man, :omar]}
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
          %AddBelief{name: :cost,
          params: [:car,
           %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1,
            params: [:X]}]},
          %AddBelief{name: :cost,
          params: [%AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
            params: [:Y]},
           %AstFunction{ast: {:__aliases__, [], [:Z]}, number_of_params: 1,
            params: [:Z]}]}]
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
        [%AddBelief{name: :cost, params: [:car, 10000]},
         %AddBelief{name: :money, params: 'o'},
         %AchieveGoal{name: :buy_stuff, params: []}]
    end

    test "it has a belief base with the initial" do
      ag = MockAgentWBG.create("ag2")
      bb = MockAgentWBG.belief_base(ag)
      assert BeliefBase.beliefs(bb) == []
    end
  end

end
