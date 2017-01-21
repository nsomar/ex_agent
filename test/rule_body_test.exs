defmodule RuleBodyTest do
  use ExUnit.Case

  test "it can parse 1 belief base from macro" do
    # do: man(:omar)
    bb = [do: {:man, [line: 10], [:omar]}]

    assert RuleBody.parse(bb) == [{:belief, {:man, {:omar}}}  ]
  end

  test "it can parse multiple beliefs base from macro" do
    # .... do
    #   cost(:car, 1000)
    #   cost(:iphone, 1000)
    #   ...
    # end

    bb = [do: {:__block__, [],
  [{:cost, [line: 5], [:car, 10000]}, {:cost, [line: 6], [:iphone, 500]},
   {:color, [line: 7], [:car, :red]}, {:color, [line: 8], [:iphone, :black]},
   {:is, [line: 9], [:man, :omar]}]}]

    assert RuleBody.parse(bb) ==
      [belief: {:cost, {:car, 10000}}, belief: {:cost, {:iphone, 500}}, belief: {:color, {:car, :red}}, belief: {:color, {:iphone, :black}}, belief: {:is, {:man, :omar}}]
  end

  test "can parse goals and beliefs when goals have no parameters" do
    # .... do
    #   cost(:car, 1000)
    #   !buy()
    #   ...
    # end

    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], Elixir}]}
    ]}]

    assert RuleBody.parse(bb) == [belief: {:money, {111}}, goal: {:buy, []}]
  end

  test "can parse goals and beliefs when goals have empty parameters" do
    # .... do
    #   cost(:car, 1000)
    #   !buy()
    #   ...
    # end

    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], []}]}
    ]}]
    assert RuleBody.parse(bb) == [belief: {:money, {111}}, goal: {:buy, []}]
  end

  test "can parse goals and beliefs when goals have parameters" do
    # .... do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    #   ...
    # end

    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], ["car", 1]}]}
    ]}]
    assert RuleBody.parse(bb) == [belief: {:money, {111}}, goal: {:buy, ["car", 1]}]
  end

end
