defmodule RuleTriggerTest do
  use ExUnit.Case

  test "can get the added_belief trigger type" do
    # rule (+cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:+, [line: 24],
  [{:cost, [line: 24], [:car, {:__aliases__, [counter: 0, line: 24], [:X]}]}]}

    assert RuleTrigger.parse(trigger).event_type ==
    TriggerType.added_belief
  end

  test "can get the added_goal trigger type" do
    # rule (+!cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:+, [line: 86],
  [{:!, [line: 86],
    [{:cost, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]}]}

    assert RuleTrigger.parse(trigger).event_type ==
    TriggerType.added_goal
  end

  test "can get the added_goal trigger type when no params are passed" do
    # rule (+!cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:+, [line: 86], [{:!, [line: 86], [{:cost, [line: 86], nil}]}]}

    assert RuleTrigger.parse(trigger).event_type ==
    TriggerType.added_goal
  end

  test "can get the removed_belief trigger type" do
    # rule (-cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:-, [line: 85],
    [{:cost, [line: 85], [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}
    assert RuleTrigger.parse(trigger).event_type ==
    TriggerType.removed_belief
  end

  test "can get the removed_goal trigger type" do
    # rule (-!cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:-, [line: 85],
  [{:!, [line: 85],
    [{:cost, [line: 85],
      [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}]}

    assert RuleTrigger.parse(trigger).event_type ==
    TriggerType.removed_goal
  end

  test "can get the added_belief trigger event" do
    # rule (+cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:+, [line: 85],
    [{:cost, [line: 85], [:car, {:__aliases__, [counter: 0, line: 85], [:X]}]}]}
    assert RuleTrigger.parse(trigger).content ==
    {:cost, {:car, :X}}
  end

  test "can get the added_goal trigger event" do
    # rule (+cost(:car, X)) do
    #   cost(:car, 1000)
    #   !buy(:car, 1)
    # end

    trigger = {:+, [line: 85], [{:!, [line: 85], [{:cost, [line: 85], [:car, 100]}]}]}

    assert RuleTrigger.parse(trigger).content ==
    {:cost, {:car, 100}}
  end

  test "can get the added_goal trigger event 2" do
    # as above

    trigger = {:+, [line: 86],
  [{:!, [line: 86],
    [{:cost, [line: 86], [{:__aliases__, [counter: 0, line: 86], [:X]}]}]}]}

    assert RuleTrigger.parse(trigger).content ==
    {:cost, {:X}}
  end

end
