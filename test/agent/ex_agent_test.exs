defmodule ExagentTest do
  use ExUnit.Case
  doctest ExAgent

  test "can get the beleif base" do
    agent = ExAgent.create(:"name1")
    val = ExAgent.beliefs(agent)
    assert val != nil
  end

  test "can get the beleifs" do
    agent = ExAgent.create(:"name2")
    res = ExAgent.add_belief(agent, {:abcd})

    assert res == {:added, [{:abcd}]}
    assert ExAgent.beliefs(agent) == [{:abcd}]
  end

  test "can get remove a belief" do
    agent = ExAgent.create(:"name2")

    res = ExAgent.add_beliefs(agent, [{:abcd}])
    assert res == %AgentState{beliefs: [{:abcd}], events: [], intents: [], messages: [],
            module: ExAgent, name: :name2, plan_rules: [], message_handlers: [], recovery_handlers: []}

    res = ExAgent.remove_belief(agent, {:abcd})
    assert res == {:removed, []}

    assert ExAgent.beliefs(agent) == []
  end

end
