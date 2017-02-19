defmodule Reasoner.IntentTest do
  use ExUnit.Case

  @add_goal_event  %Event{event_type: :added_goal, intents: nil, content: {}}
  @achieve_goal %AchieveGoal{name: :count, params: []}

  describe "process_intents" do
    test "it creates a new intent for the event if there is a plan" do
      {:ok, [new| old]} = Reasoner.Intent.process_intents([], @add_goal_event, %{body: [B]}, [1])

      assert new == %Intention{executions: [%IntentionExecution{instructions: [B], plan: %{body: [B]}, bindings: [1], event: %Event{content: {}, event_type: :added_goal, intents: nil}}]}
      assert old == []
    end

    test "it returns same intent if there are no plans" do
      event = %Event{event_type: :added_goal, content: {}}
      {:ok, [new| old]} = Reasoner.Intent.process_intents([I], event, :no_plan, [])

      assert new == I
      assert old == []
    end

    test "it does not create a new intent for goals" do
      event = %Event{event_type: :added_goal, content: {}}
      intents = [Intention.create([I1, I2])]
      plan = %{body: [B1, B2]}
      {:ok, [new| old]} = Reasoner.Intent.process_intents(intents, event, plan, [X])

      assert new ==
      %Intention{executions: [%IntentionExecution{bindings: [X],
                    event: %Event{content: {}, event_type: :added_goal, intents: nil},
                    instructions: [B1, B2], plan: %{body: [B1, B2]}},
                   %IntentionExecution{bindings: [], event: nil,
                    instructions: [I1, I2], plan: nil}]}

      assert old == []
    end

    test "it creates a new intent for add beliefs" do
      event = %Event{event_type: :added_belief, content: {}}
      intents = [Intention.create([I1, I2])]
      plan = %{body: [B1, B2]}
      {:ok, [new| old]} = Reasoner.Intent.process_intents(intents, event, plan, [X])

      assert new ==
      %Intention{executions: [%IntentionExecution{bindings: [X], instructions: [B1, B2], plan: %{body: [B1, B2]}, event: %Event{content: {}, intents: nil, event_type: :added_belief}}]}

      assert old == [%Intention{executions: [%IntentionExecution{bindings: [], event: nil, instructions: [I1, I2], plan: nil}]}]
    end

    test "it creates a new intent for received message" do
      event = %Event{event_type: :received_message, content: {}}
      intents = [Intention.create([I1, I2])]
      plan = %{body: [B1, B2]}
      {:ok, [new| old]} = Reasoner.Intent.process_intents(intents, event, plan, [X])

      assert new ==
      %Intention{executions: [%IntentionExecution{bindings: [X], instructions: [B1, B2], plan: %{body: [B1, B2]}, event: %Event{content: {}, intents: nil, event_type: :received_message}}]}

      assert old == [%Intention{executions: [%IntentionExecution{bindings: [], event: nil, instructions: [I1, I2], plan: nil}]}]
    end
  end

  describe "select_intent" do

    test "it selects an intent" do
      {:ok, current, others} = Reasoner.Intent.select_intent([I, J])
      assert current == I
      assert others == [J]
    end

    test "if no intents return no intent" do
      res = Reasoner.Intent.select_intent([])
      assert res == :no_intent
    end

  end

  describe "execute_intent" do

    test "achieve goal creates an event" do
      intent = Intention.create([@achieve_goal])
      {:ok, event, intent, beliefs} = Reasoner.Intent.execute_intent([], intent)

      assert event == [%Event{content: {:count, {}}, event_type: :added_goal, intents: nil}]
      assert intent == %Intention{executions: []}
      assert beliefs == []
    end

    test "add belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %AddBelief{name: :car, params: [:blue]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{content: {:car, {:blue}}, event_type: :added_belief, intents: nil}]
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [car: {:red}, car: {:blue}]
    end

    test "duplicate belief does not create an event" do
      beliefs = [{:car, {:red}}]
      instruction = %AddBelief{name: :car, params: [:red]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [car: {:red}]
    end

    test "removes a belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %RemoveBelief{name: :car, params: [:red]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief}]
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == []
    end

    test "not found belief does not create an event" do
      beliefs = [{:car, {:blue}}]
      instruction = %RemoveBelief{name: :car, params: [:red]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [car: {:blue}]
    end

    test "internal action does not create an event" do
      beliefs = [{:car, {:red}}]
      instruction = %InternalAction{name: :car, params: [:red]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == []
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == beliefs
    end

    test "replace belief creates an event" do
      beliefs = [{:car, {:red}}]
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [
        %Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief},
        %Event{intents: nil, content: {:car, {:blue}}, event_type: :added_belief}
      ]
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [{:car, {:blue}}]
    end

    test "replace belief creates an event without a remove" do
      beliefs = []
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [%Event{intents: nil, content: {:car, {:blue}}, event_type: :added_belief}]
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [{:car, {:blue}}]
    end

    test "replace belief creates an event with multiple removes" do
      beliefs = [{:car, {:red}}, {:car, {:pink}}]
      instruction = %ReplaceBelief{name: :car, params: [:blue]}
      bindings = []
      intent = Intention.create([instruction], nil, bindings)

      {:ok, event, new_intent, new_beliefs} = Reasoner.Intent.execute_intent(beliefs, intent)

      assert event == [
        %Event{intents: nil, content: {:car, {:red}}, event_type: :removed_belief},
        %Event{content: {:car, {:pink}}, event_type: :removed_belief, intents: nil},
        %Event{content: {:car, {:blue}}, event_type: :added_belief, intents: nil}
      ]
      assert new_intent == %Intention{executions: []}
      assert new_beliefs == [{:car, {:blue}}]

    end
  end

  describe "build_new_intents" do

    test "it builds a new intent with interleaving" do
      intent = Intention.create([@achieve_goal], nil, [])
      res = Reasoner.Intent.build_new_intents(intent, [X])
      assert res == [
        X,
        %Intention{executions: [%IntentionExecution{bindings: [], event: nil, instructions: [%AchieveGoal{name: :count, params: []}], plan: nil}]},
      ]
    end

    test "it builds a new intent by removing the one without instructions" do
      intent = Intention.create([], nil, [])
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

    test "intent interleaving" do
      intent1 = Intention.create([I11, I12,], nil, [])
      intent2 = Intention.create([I21, I22,], nil, [])
      intents = [intent1, intent2]

      {:ok, current, rest} = Reasoner.Intent.select_intent(intents)
      assert current == intent1

      intents = Reasoner.Intent.build_new_intents(current, rest)
      {:ok, current, _} = Reasoner.Intent.select_intent(intents)
      assert current == intent2
    end

  end

  describe "handling errors" do
    test "handling query not found error" do
     beliefs = [{:car, {:red}}]
     instruction = %QueryBelief{name: :car, params: [:blue]}
     bindings = []
     event = Event.from_instruction(instruction, bindings)
     intent = Intention.create([instruction], event, bindings)

     result = Reasoner.Intent.execute_intent(beliefs, intent)

     assert result == {
      :execution_error,
      %Intention{executions: []},
      %QueryBelief{name: :car, params: [:blue]},
      %Event{content: %QueryBelief{name: :car, params: [:blue]}, event_type: :query_belief, intents: nil}
    }
    end

    test "handling query not found error 2" do
     beliefs = [{:car, {:red}}]
     instruction = %QueryBelief{name: :sell, params: [X]}
     bindings = []
     event = Event.from_instruction(instruction, bindings)
     intent = Intention.create([instruction], event, bindings)

     result = Reasoner.Intent.execute_intent(beliefs, intent)

     assert result == {
      :execution_error,
      %Intention{executions: []},
      %QueryBelief{name: :sell, params: [X]},
      %Event{content: %QueryBelief{name: :sell, params: [X]}, event_type: :query_belief, intents: nil}
    }
    end
  end
end
