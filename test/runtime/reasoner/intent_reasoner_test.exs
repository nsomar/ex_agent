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
      res = Reasoner.Intent.execute_intent([], :no_intent)

      assert res == :no_intent
    end

    test "achieve goal creates an event" do
      intent = %Intention{instructions: [@achieve_goal], bindings: []}
      {event, intent, beliefs} = Reasoner.Intent.execute_intent([], intent)

      assert event == [%Event{content: {:count, {}}, event_type: :added_goal, intents: nil}]
      assert intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert beliefs == []
    end

    test "add belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %AddBelief{name: :car, params: [:blue]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{content: {:car, {:blue}}, event_type: :added_belief, intents: nil}]
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [car: {:red}, car: {:blue}]
    end

    test "duplicate belief does not create an event" do
      beliefs = [{:car, {:red}}]
      instruction = %AddBelief{name: :car, params: [:red]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [car: {:red}]
    end

    test "removes a belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %RemoveBelief{name: :car, params: [:red]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief}]
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == []
    end

    test "not found belief does not create an event" do
      beliefs = [{:car, {:blue}}]
      instruction = %RemoveBelief{name: :car, params: [:red]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [car: {:blue}]
    end

    test "internal action does not create an event" do
      beliefs = [{:car, {:red}}]
      instruction = %InternalAction{name: :car, params: [:red]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == beliefs
    end

    test "replace belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [
        %Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief},
        %Event{intents: nil, content: {:car, {:blue}}, event_type: :added_belief}
      ]
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [{:car, {:blue}}]
    end

    test "replace belief creates an event without a remove" do
      beliefs = []
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{intents: nil, content: {:car, {:blue}}, event_type: :added_belief}]
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [{:car, {:blue}}]
    end

    test "replace belief creates an event with multiple removes" do
      beliefs = [{:car, {:red}}, {:car, {:pink}}]
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = %Intention{instructions: [instruction], bindings: bindings}

      {event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [
        %Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief},
        %Event{content: {:car, {:pink}}, event_type: :removed_belief, intents: nil},
        %Event{content: {:car, {:blue}}, event_type: :added_belief, intents: nil}
      ]
      assert new_intent == %Intention{bindings: [], instructions: [], plan: nil}
      assert new_beliefs == [{:car, {:blue}}]
    end

  end

  describe "build_new_intents" do

    test "it builds a new intent" do
      intent = %Intention{instructions: [@achieve_goal], bindings: []}
      res = Reasoner.Intent.build_new_intents(intent, [X])
      assert res == [
        %Intention{bindings: [], instructions: [%AchieveGoal{name: :count, params: []}], plan: nil},
        X
      ]
    end

    test "it builds a new intent by removing the one without instructions" do
      intent = %Intention{instructions: [], bindings: []}
      res = Reasoner.Intent.build_new_intents(intent, [X])
      assert res == [
        X
      ]
    end

    test "it builds a new intent by removing the :no_intent" do
      res = Reasoner.Intent.build_new_intents(:no_intent, [X])
      assert res == [
        X
      ]
    end

  end

end
