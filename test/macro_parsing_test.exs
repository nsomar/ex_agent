defmodule MacroParsingTest do
  use ExUnit.Case

  test "it can parse 1 belief base from macro" do
    bb = [do: {:man, [line: 10], [:omar]}]

    assert Parsing.Macro.parse_beliefs(bb) == [{:man, {:omar}}]
  end

  test "it can parse multiple beliefs base from macro" do
    bb = [do: {:__block__, [],
  [{:cost, [line: 5], [:car, 10000]}, {:cost, [line: 6], [:iphone, 500]},
   {:color, [line: 7], [:car, :red]}, {:color, [line: 8], [:iphone, :black]},
   {:is, [line: 9], [:man, :omar]}]}]

    assert Parsing.Macro.parse_beliefs(bb) ==
      [
        {:cost, {:car, 10000}},
        {:cost, {:iphone, 500}},
        {:color, {:car, :red}},
        {:color, {:iphone, :black}},
        {:is, {:man, :omar}},
      ]
  end

  test "can parse goals and beliefs when goals have no parameters" do
    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], Elixir}]}
    ]}]
    assert Parsing.Macro.parse_beliefs(bb) == [{:money, {111}}]
    assert Parsing.Macro.parse_goals(bb) == [{:buy, []}]
  end

  test "can parse goals and beliefs when goals have empty parameters" do
    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], []}]}
    ]}]
    assert Parsing.Macro.parse_beliefs(bb) == [{:money, {111}}]
    assert Parsing.Macro.parse_goals(bb) == [{:buy, []}]
  end

  test "can parse goals and beliefs when goals have parameters" do
    bb = [do:
    {:__block__, [],[
      {:money, [], 'o'},
      {:!, [context: Elixir, import: Kernel], [{:buy, [], ["car", 1]}]}
    ]}]
    assert Parsing.Macro.parse_beliefs(bb) == [{:money, {111}}]
    assert Parsing.Macro.parse_goals(bb) == [{:buy, ["car", 1]}]
  end

  test "can get the added_belief trigger type" do
    trigger = {{:+, [line: 85],
    [{:cost, [line: 85], [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}}
    assert Parsing.Macro.parse_trigger(trigger) |> elem(0) ==
    TriggerType.added_belief
  end

  test "can get the added_goal trigger type" do
    trigger = {{:+, [line: 86],
  [{:!, [line: 86],
    [{:cost, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]}]}}

    assert Parsing.Macro.parse_trigger(trigger) |> elem(0) ==
    TriggerType.added_goal
  end

  test "can get the removed_belief trigger type" do
    trigger = {{:-, [line: 85],
    [{:cost, [line: 85], [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}}
    assert Parsing.Macro.parse_trigger(trigger) |> elem(0) ==
    TriggerType.removed_belief
  end

  test "can get the removed_goal trigger type" do
    trigger = {{:-, [line: 85],
  [{:!, [line: 85],
    [{:cost, [line: 85],
      [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}]}}

    assert Parsing.Macro.parse_trigger(trigger) |> elem(0) ==
    TriggerType.removed_goal
  end

  test "can get the added_belief trigger event" do
    trigger = {{:+, [line: 85],
    [{:cost, [line: 85], [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}}
    assert Parsing.Macro.parse_trigger(trigger) |> elem(1) ==
    {:cost, {:car, :X}}
  end

  test "can get the added_goal trigger event" do
    trigger = {{:+, [line: 85], [{:!, [line: 85], [{:cost, [line: 85], [:car, 100]}]}]}}

    assert Parsing.Macro.parse_trigger(trigger) |> elem(1) ==
    {:cost, {:car, 100}}
  end

  test "can get the added_goal trigger event 2" do
    trigger = {{:+, [line: 86],
  [{:!, [line: 86],
    [{:cost, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]}]}}

    assert Parsing.Macro.parse_trigger(trigger) |> elem(1) ==
    {:cost, {:X}}
  end

  test "can parse the rule with single context" do
    context = {{:nice, [line: 86],
  [{:__aliases__, [counter: 0, line: 86], [:X]},
   {:__aliases__, [counter: 0, line: 86], [:Z]}]}}

    assert Parsing.Macro.parse_rule_context(context) ==
    [{:nice, {:X, :Z}}]
  end

  test "can parse the rule context without tailing functions" do
    context = {{:&&, [line: 86],
  [{:money, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:Y]}]},
   {:nice, [line: 86],
    [{:__aliases__, [counter: 0, line: 86], [:X]},
     {:__aliases__, [counter: 0, line: 86], [:Z]}]}]}}

    assert Parsing.Macro.parse_rule_context(context) ==
    [{:money, {:Y}}, {:nice, {:X, :Z}}]
  end

  test "can parse the rule context with 3 contextes" do
    context = {{:&&, [line: 86],
  [{:&&, [line: 86],
    [{:money, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:Z]}]},
     {:nice, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]},
   {:want_to_buy, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]}}

    assert Parsing.Macro.parse_rule_context(context) ==
    [{:money, {:Z}}, {:nice, {:X}}, {:want_to_buy, {:X}}]
  end

  test "can parse the rule context with tailing functions" do
    context = {{:&&, [line: 86],
  [{:&&, [line: 86],
    [{:money, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:Z]}]},
     {:nice, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]},
   {:>, [line: 86],
    [{:__aliases__, [counter: 0, line: 86], [:Z]},
     {:__aliases__, [counter: 0, line: 86], [:Y]}]}]}}

    assert Parsing.Macro.parse_rule_context(context) ==
    {[{:money, {:Z}}, {:nice, {:X}}], 1}
  end

end
