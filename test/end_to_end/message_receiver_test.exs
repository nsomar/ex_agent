defmodule MessageReceiverAgent do
  use ExAgent

  message(:inform, sender, echo(X)) do
    &print("Received #{inspect(X)}")
  end

  start
end

defmodule MessageReceiverTest do
  use ExUnit.Case

  test "it receives a message" do
    ag = MessageReceiverAgent.create("agent1")
    name = MessageReceiverAgent.agent_name("agent1")

    ActualMessageSender.send_message(name, :inform, :echo, ["Hey"])
    assert ExAgent.messages(ag) == [
      %Message{name: :echo, params: ["Hey"], performative: :inform, from: self()}
    ]
  end

  test "it receives 2 messages" do
    ag = MessageReceiverAgent.create("agent2")
    name = MessageReceiverAgent.agent_name("agent2")

    ActualMessageSender.send_message(name, :inform, :echo, ["Hey1"])
    ActualMessageSender.send_message(name, :inform, :echo, ["Hey2"])
    assert ExAgent.messages(ag) == [
      %Message{name: :echo, params: ["Hey2"], performative: :inform, from: self()},
      %Message{name: :echo, params: ["Hey1"], performative: :inform, from: self()}
    ]
  end

end
