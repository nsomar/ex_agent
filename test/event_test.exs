defmodule EventTest do
  use ExUnit.Case

  test "it can create an added_belief event" do
    res = Event.added_belief({:bbb})
    assert res == %Event{event_type: :added_belief, content: {:bbb}}
  end

   test "it can create a removed_belief event" do
    res = Event.removed_belief({:bbb})
    assert res == %Event{event_type: :removed_belief, content: {:bbb}}
  end

   test "it can create an added_goal event" do
    res = Event.added_goal(:g)
    assert res == %Event{event_type: :added_goal, content: :g}
  end

   test "it can create a removed_goal event" do
    res = Event.removed_goal(:g)
    assert res == %Event{event_type: :removed_goal, content: :g}
  end

   test "it can create an added_test_goal event" do
    res = Event.added_test_goal(:g)
    assert res == %Event{event_type: :added_test_goal, content: :g}
  end

   test "it can create a removed_test_goal event" do
    res = Event.removed_test_goal(:g)
    assert res == %Event{event_type: :removed_test_goal, content: :g}
  end

end
