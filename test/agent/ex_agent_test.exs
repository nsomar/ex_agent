use ExAgent

defagent MyAgentTest123 do
end

defmodule ExagentTest do
  use ExUnit.Case
  doctest ExAgent

  test "can get the beleif base" do
    agent = ExAgent.Mod.create_agent(MyAgentTest123, :"name1")
    val = ExAgent.Mod.beliefs(agent)
    assert val != nil
  end

  test "can get the beleifs" do
    agent = ExAgent.Mod.create_agent(MyAgentTest123, :"name2")
    res = ExAgent.Mod.add_belief(agent, {:abcd})

    assert res == {:added, [{:abcd}]}
    assert ExAgent.Mod.beliefs(agent) == [{:abcd}]
  end

  test "can get remove a belief" do
    agent = ExAgent.Mod.create_agent(MyAgentTest123, :"name2")

    res = ExAgent.Mod.add_beliefs(agent, [{:abcd}])
    assert res == %AgentState{beliefs: [{:abcd}], events: [], intents: [], messages: [],
            module: ExAgent.Mod, name: :"Elixir.MyAgentTest123.name2", plan_rules: [], message_handlers: [], recovery_handlers: []}

    res = ExAgent.Mod.remove_belief(agent, {:abcd})
    assert res == {:removed, []}

    assert ExAgent.Mod.beliefs(agent) == []
  end

end
