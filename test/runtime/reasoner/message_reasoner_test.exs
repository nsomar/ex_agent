defmodule Reasoner.MessageTest do
  use ExUnit.Case

  test "it process messages" do
    messages = [
      %Message{name: :echo, params: ["Hey2"], performative: :inform},
      %Message{name: :echo, params: ["Hey1"], performative: :inform}
    ]

    events = Reasoner.Message.process_messages(messages)
    assert events == [
      %Event{content: %Message{name: :echo, params: ["Hey2"], performative: :inform}, event_type: :received_message, intents: nil},
      %Event{content: %Message{name: :echo, params: ["Hey1"], performative: :inform}, event_type: :received_message, intents: nil}
    ]
  end

  test "it process empty messages" do
    events = Reasoner.Message.process_messages([])
    assert events == []
  end
end
