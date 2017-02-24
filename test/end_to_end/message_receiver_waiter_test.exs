use ExAgent

defagent MessageReceiverWaitAgent do
  message(:inform, sender, add(X)) do
    +state(X)
    &print("Received #{inspect(X)}")
  end
end

defmodule MessageReceiverWaiterTest do
  use ExUnit.Case

  test "it waits until message are sent" do
    ag = MessageReceiverWaitAgent.create("agent")
    MessageReceiverWaitAgent.run_loop(ag)
    Process.sleep(100)
    name = MessageReceiverWaitAgent.agent_name("agent")
    ExAgent.send_message(name, :inform, :add, [10])
    Process.sleep(100)
    assert ExAgent.Mod.beliefs(ag) == [state: {10}]
  end

  test "it waits until message are sent 2" do
    ag = MessageReceiverWaitAgent.create("agent")
    MessageReceiverWaitAgent.run_loop(ag)
    Process.sleep(100)
    MessageReceiverWaitAgent.send_message("agent", :inform, :add, [10])
    Process.sleep(100)
    assert ExAgent.Mod.beliefs(ag) == [state: {10}]
  end

  test "it can be started from agent creator" do
    ag = start_agent(MessageReceiverWaitAgent, "agent")
    Process.sleep(100)
    send_message(MessageReceiverWaitAgent, "agent", :inform, :add, [10])
    Process.sleep(100)
    assert ExAgent.Mod.beliefs(ag) == [state: {10}]
  end

end
