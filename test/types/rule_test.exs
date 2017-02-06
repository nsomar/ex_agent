defmodule RuleTest do
  use ExUnit.Case

  test "it can parse a rule" do

    # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
    #   +nice(:car)
    #   !buy(X)
    #   &send(X)
    # end

    body =
      [do: {:__block__, [],
        [{:+, [line: 14], [{:nice, [line: 14], [:car]}]},
         {:!, [line: 15],
          [{:buy, [line: 15], [{:__aliases__, [counter: 0, line: 15], [:X]}]}]},
         {:&, [line: 16],
          [{:send, [line: 16], [{:__aliases__, [counter: 0, line: 16], [:X]}]}]}]}]


    head =
      {:when, [line: 13],
       [{:+, [line: 13],
         [{:!, [line: 13],
           [{:buy, [line: 13], [{:__aliases__, [counter: 0, line: 13], [:X]}]}]}]},
        {:&&, [line: 13],
         [{:&&, [line: 13],
           [{:money, [line: 13], [{:__aliases__, [counter: 0, line: 13], [:Z]}]},
            {:cost, [line: 13],
             [{:__aliases__, [counter: 0, line: 13], [:X]},
              {:__aliases__, [counter: 0, line: 13], [:C]}]}]},
          {:test, [line: 13],
           [{:&&, [line: 13],
             [{:>, [line: 13],
               [{:__aliases__, [counter: 0, line: 13], [:Z]},
                {:__aliases__, [counter: 0, line: 13], [:X]}]},
              {:test, [line: 13],
               [{:==, [line: 13],
                 [{:__aliases__, [counter: 0, line: 13], [:Z]},
                  {:__aliases__, [counter: 0, line: 13], [:X]}]}]}]}]}]}]}


    # IO.inspect(Rule.parse(head, body))
    assert Rule.parse(head, body) ==
      %Rule{body: [%AddBelief{name: :nice, params: [:car]},
        %AchieveGoal{g: {:buy, [:X]}}, %InternalAction{a: {:send, {:X}}}],
       head: %RuleHead{context: %RuleContext{contexts: [%ContextBelief{belief: {:money,
            {:Z}}, should_pass: true},
          %ContextBelief{belief: {:cost, {:X, :C}}, should_pass: true}],
         function: %AstFunction{ast: {:&&, [],
           [{:>, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:X]}]},
            {:==, [], [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:X]}]}]},
          number_of_params: 2, params: [:Z, :X]}},
        trigger: %RuleTrigger{content: {:buy, {:X}}, event_type: :added_goal}}}
  end

end
