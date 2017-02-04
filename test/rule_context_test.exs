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
    %RuleTrigger{event_type: :added_goal, content: {:buy, {:X}}}
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

    ctxs = [
      ContextBelief.create({:is_nice, {:X}}, true),
    ]

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: ctxs, function: nil}
    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event_type: :added_goal, content: {:buy, {:X}}}
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

    ctxs = [
      ContextBelief.create({:money, {:Y}}, true),
      ContextBelief.create({:nice, {:X, :Z}}, true),
    ]

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: ctxs, function: nil}
    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event_type: :added_goal, content: {:buy, {:X}}}
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

    ctxs = [
      ContextBelief.create({:money, {:Y}}, true),
      ContextBelief.create({:nice, {:X, :Z}}, true),
      ContextBelief.create({:want_to_buy, {:X}}, true),
    ]

    assert RuleContext.parse(context) ==
    %RuleContext{contexts: ctxs, function: nil}

    assert RuleTrigger.parse(context) ==
    %RuleTrigger{event_type: :added_goal, content: {:buy, {:X}}}
  end

  test "can parse the rule context with single case test" do
    # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X

    context =
      {:when, [line: 11],
       [{:+, [line: 11],
         [{:!, [line: 11],
           [{:buy, [line: 11], [{:__aliases__, [counter: 0, line: 11], [:X]}]}]}]},
        {:&&, [line: 11],
         [{:&&, [line: 11],
           [{:money, [line: 11], [{:__aliases__, [counter: 0, line: 11], [:Z]}]},
            {:cost, [line: 11],
             [{:__aliases__, [counter: 0, line: 11], [:X]},
              {:__aliases__, [counter: 0, line: 11], [:C]}]}]},
          {:test, [line: 11],
           [{:>, [line: 11],
             [{:__aliases__, [counter: 0, line: 11], [:Z]},
              {:__aliases__, [counter: 0, line: 11], [:X]}]}]}]}]}

    rh = RuleHead.parse(context)
    assert rh.context.contexts ==
    [%ContextBelief{belief: {:money, {:Z}}, should_pass: true}, %ContextBelief{belief: {:cost, {:X, :C}}, should_pass: true}]
    assert rh.context.function.params == [:Z, :X]
  end
end
