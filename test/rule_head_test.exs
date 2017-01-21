defmodule RuleHeadTest do
  use ExUnit.Case

  test "it parses rule head" do
    rule =
      {:when, [line: 24],
       [{:+, [line: 24],
         [{:!, [line: 24],
           [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]},
        {:&&, [line: 24],
         [{:&&, [line: 24],
           [{:cost, [line: 24],
             [{:__aliases__, [counter: 0, line: 24], [:X]},
              {:__aliases__, [counter: 0, line: 24], [:Y]}]},
            {:money, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:Z]}]}]},
          {:test, [line: 24],
           [{:>=, [line: 24],
             [{:__aliases__, [counter: 0, line: 24], [:Z]},
              {:__aliases__, [counter: 0, line: 24], [:Y]}]}]}]}]}

    rh = RuleHead.parse(rule)
    assert rh.trigger == %RuleTrigger{event: :added_goal, trigger: {:buy, {:X}}}
    assert rh.context == %RuleContext{contexts: [cost: {:X, :Y}, money: {:Z}],
            function: %ContextFunction{ast: {:>=, [],
              [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:Y]}]},
             number_of_params: 2, params: [:Z, :Y]}}
  end
end
