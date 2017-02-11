defmodule Reasoner.EventTest do
  use ExUnit.Case

  test "it selects an event" do
    events = [Event1, Event2]
    {current, rest} = Reasoner.Event.select_event(events)
    assert current == Event1
  end

  test "it returns no event if no events are found" do
    events = []
    {current, rest} = Reasoner.Event.select_event(events)
    assert current == :no_event
    assert rest == []
  end

  test "it builds new list of events" do
    events = [Event1, Event2]
    new_events = Reasoner.Event.build_new_events(Event3, events)
    assert new_events == [Event1, Event2, Event3]
  end

  test "it returns old events if no event" do
    events = [Event1, Event2]
    new_events = Reasoner.Event.build_new_events(:no_event, events)
    assert new_events == [Event1, Event2]
  end
end
