defmodule Reasoner.IntentTest do
  use ExUnit.Case

  @add_goal_event  %Event{event_type: :added_goal, intents: nil, content: {}}
  @achieve_goal %AchieveGoal{name: :count, params: []}

  describe "process_intents" do
    test "it creates a new intent for the event if there is a plan" do
      {[new| old], _} = Reasoner.Intent.process_intents([], @add_goal_event, %{body: [B]}, [1])

      assert new.bindings == [1]
      assert new.instructions == [B]
      assert old == []
    end

    test "it returns same intent if there are no plans" do
      event = %Event{event_type: :added_goal, content: {}}
      {[new| old], _} = Reasoner.Intent.process_intents([I], event, :no_plan, [])

      assert new == I
      assert old == []
    end
  end

  describe "select_intent" do

    test "it selects an intent" do
      {current, others} = Reasoner.Intent.select_intent([I, J])
      assert current == I
      assert others == [J]
    end

    test "if no intents return no intent" do
      {current, others} = Reasoner.Intent.select_intent([])
      assert current == :no_intent
      assert others == []
    end

  end

  describe "execute_intent" do

    test "it returns no intent, no event if no intents" do
      {event, intent} = Reasoner.Intent.execute_intent(S, :no_intent)
      assert event == :no_event
      assert intent == :no_intent
    end

    test "it executes the first instruction in the intent" do
      intent = %Intention{instructions: [@achieve_goal], bindings: []}
      {event, intent, beliefs} = Reasoner.Intent.execute_intent(S, intent)

      assert event == %Event{content: {:count, {}}, event_type: :added_goal, intents: nil}
      assert intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert beliefs == S
    end

  end

end
