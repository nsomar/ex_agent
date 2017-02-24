use ExAgent

defagent AgentRegistryTestAgent do
end

defmodule AgentRegistryTest do
  use ExUnit.Case

  test "registers the agent" do
    ExAgent.Registry.init
    ExAgent.Registry.register_agent(AgentRegistryTestAgent, "abc", "123")
    assert ExAgent.Registry.find(AgentRegistryTestAgent, "abc") == "123"
  end

  test "returns not found if not found" do
    ExAgent.Registry.init
    ExAgent.Registry.register_agent(AgentRegistryTestAgent, "abc123", "123")
    assert ExAgent.Registry.find(AgentRegistryTestAgent, "abc") == :not_found
  end

  test "it finds agent by name and module" do
    ExAgent.Registry.init
    ag = start_agent(AgentRegistryTestAgent, "blabla1")
    assert ExAgent.Registry.find(AgentRegistryTestAgent, "blabla1") == ag
  end

  test "it finds all agents by name" do
    ExAgent.Registry.init
    ag = start_agent(AgentRegistryTestAgent, "blabla2")
    assert ExAgent.Registry.find_by_name("blabla2") ==
    [{AgentRegistryTestAgent, "blabla2", ag}]
  end

  test "it finds all agents by module" do
    ExAgent.Registry.init
    ag = start_agent(AgentRegistryTestAgent, "blabla3")
    assert ExAgent.Registry.find_by_module(AgentRegistryTestAgent) ==
    [{AgentRegistryTestAgent, "blabla3", ag}]
  end

  test "it can unregister an agent" do
    ExAgent.Registry.init
    ag = start_agent(AgentRegistryTestAgent, "blabla4")
    assert ExAgent.Registry.find_by_module(AgentRegistryTestAgent) ==
    [{AgentRegistryTestAgent, "blabla4", ag}]

    ExAgent.Registry.unregister_agent(AgentRegistryTestAgent, "blabla4")
    assert ExAgent.Registry.find_by_module(AgentRegistryTestAgent) ==
    []
  end

  test "it can unregister an agent when gen exits" do
    ExAgent.Registry.init
    ag = start_agent(AgentRegistryTestAgent, "blabla5", false)
    assert ExAgent.Registry.find_by_module(AgentRegistryTestAgent) ==
    [{AgentRegistryTestAgent, "blabla5", ag}]

    # Process.sleep(100)
    ExAgent.stop_agent(AgentRegistryTestAgent, "blabla5")
    Process.sleep(100)
    assert ExAgent.Registry.find_by_module(AgentRegistryTestAgent) == []

  end

end
