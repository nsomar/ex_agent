defmodule RuleContextTest do
  use ExUnit.Case

  test "can parse the rule with no context" do

    # rule (+!buy(X))

    context =
      {:+, [line: 19],
 [{:!, [line: 19],
   [{:buy, [line: 19], [{:__aliases__, [counter: 0, line: 19], [:X]}]}]}]}

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: [], function: nil}
    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event: :added_goal, trigger: {:buy, {:X}}}
  end

  test "can parse the rule with single context" do

    # rule (+!buy(X)) when is_nice(X)

    context =
      {:when, [line: 24],
       [{:+, [line: 24],
         [{:!, [line: 24],
           [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]},
        {:is_nice, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}
      [do: nil]
      {:+, [line: 24],
       [{:!, [line: 24],
         [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]}

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: [is_nice: {:X}], function: nil}
    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event: :added_goal, trigger: {:buy, {:X}}}
  end

  test "can parse the rule context without tailing functions" do
    # rule (+!buy(X)) when money(Y) && nice(X, Z)

    context =
      {:when, [line: 24],
       [{:+, [line: 24],
         [{:!, [line: 24],
           [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]},
        {:&&, [line: 24],
         [{:money, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:Y]}]},
          {:nice, [line: 24],
           [{:__aliases__, [counter: 0, line: 24], [:X]},
            {:__aliases__, [counter: 0, line: 24], [:Z]}]}]}]}
      [do: nil]
      {:+, [line: 24],
       [{:!, [line: 24],
         [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]}

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: [money: {:Y}, nice: {:X, :Z}], function: nil}
    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event: :added_goal, trigger: {:buy, {:X}}}
  end

  test "can parse the rule context with 3 contextes" do
    # rule (+!buy(X)) when money(Y) && nice(X, Z) && want_to_buy(X)

    context =
      {:when, [line: 24],
       [{:+, [line: 24],
         [{:!, [line: 24],
           [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]},
        {:&&, [line: 24],
         [{:&&, [line: 24],
           [{:money, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:Y]}]},
            {:nice, [line: 24],
             [{:__aliases__, [counter: 0, line: 24], [:X]},
              {:__aliases__, [counter: 0, line: 24], [:Z]}]}]},
          {:want_to_buy, [line: 24],
           [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]}
      [do: nil]
      {:+, [line: 24],
       [{:!, [line: 24],
         [{:buy, [line: 24], [{:__aliases__, [counter: 0, line: 24], [:X]}]}]}]}

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: [money: {:Y}, nice: {:X, :Z},
             want_to_buy: {:X}], function: nil}

    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event: :added_goal, trigger: {:buy, {:X}}}
  end

  test "can parse the rule context with single case test" do
    # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X

    context =
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

    rc = RuleContext.parse(context)
    assert rc.contexts == [{:cost, {:X, :Y}}, {:money, {:Z}}]
    assert rc.function.params == [:Z, :Y]
  end
end
