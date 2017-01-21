defmodule RuleBodyTest do
  use ExUnit.Case

  test "it can parse 1 belief base from macro" do
    # do: +man(:omar)
    bb = [do: {:+, [line: 14], [{:man, [line: 14], [:omar]}]}]

    assert RuleBody.parse(bb) == [%AddBelief{b: {:man, {:omar}}}]
  end

  test "it can parse 1 belief base from macro with alias" do
    # has_car(X)

    bb = [do: {:+, [line: 14],
  [{:has_car, [line: 14], [{:__aliases__, [counter: 0, line: 14], [:X]}]}]}]

    assert RuleBody.parse(bb) == [%AddBelief{b: {:has_car, {:X}}}]
  end

  test "it can parse removing a belief" do
    # has_car(X)

    bb = [do: {:-, [line: 14],
  [{:has_car, [line: 14], [{:__aliases__, [counter: 0, line: 14], [:X]}]}]}]

    assert RuleBody.parse(bb) == [%RemoveBelief{b: {:has_car, {:X}}}]
  end

  test "it can parse multiple beliefs base from macro" do
    # .... do
    #   cost(:car, 1000)
    #   cost(:iphone, 1000)
    #   ...
    # end

    bb = [do: {:__block__, [],
  [{:+, [line: 14], [{:cost, [line: 14], [:car, 1000]}]},
   {:-, [line: 15], [{:cost, [line: 15], [:iphone, 1000]}]},
   {:+, [line: 16], [{:is, [line: 16], [:man, :omar]}]}]}]

    assert RuleBody.parse(bb) ==
      [%AddBelief{b: {:cost, {:car, 1000}}},
       %RemoveBelief{b: {:cost, {:iphone, 1000}}},
       %AddBelief{b: {:is, {:man, :omar}}}]
  end

  test "can parse goals and beliefs when goals have no parameters" do
    # .... do
    # +money(:o)
    # !buy
    #   ...
    # end

    bb = [do: {:__block__, [],
  [{:+, [line: 14], [{:money, [line: 14], [:o]}]},
   {:!, [line: 15], [{:buy, [line: 15], nil}]}]}]

    assert RuleBody.parse(bb) == [%AddBelief{b: {:money, {:o}}}, %AchieveGoal{g: {:buy, []}}]
  end

  test "can parse goals and beliefs when goals have empty parameters" do
    # .... do
    # +money(:o)
    # !buy
    #   ...
    # end

    bb = [do: {:__block__, [],
  [{:+, [line: 14], [{:money, [line: 14], [:o]}]},
   {:!, [line: 15], [{:buy, [line: 15], []}]}]}]

    assert RuleBody.parse(bb) == [%AddBelief{b: {:money, {:o}}}, %AchieveGoal{g: {:buy, []}}]
  end

  test "can parse goals and beliefs when goals have parameters" do
    # .... do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    #   ...
    # end

    bb = [do: {:__block__, [],
  [{:+, [line: 14], [{:money, [line: 14], [:o]}]},
   {:!, [line: 15],
    [{:buy, [line: 15], [{:__aliases__, [counter: 0, line: 15], [:X]}]}]}]}]

    assert RuleBody.parse(bb) == [%AddBelief{b: {:money, {:o}}}, %AchieveGoal{g: {:buy, [:X]}}]
  end

end
