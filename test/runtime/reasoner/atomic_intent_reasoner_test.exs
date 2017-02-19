defmodule Reasoner.AtomicIntentTest do
  use ExUnit.Case

  @add_bel1 %AddBelief{name: :counter, params: [1]}
  @add_bel2 %AddBelief{name: :counter, params: [2]}
  @add_bel3 %AddBelief{name: :counter, params: [3]}

  @query_bel %QueryBelief{name: :sell, params: [X]}

  @add_ev1 %Event{content: {:counter, {1}}, event_type: :added_belief, intents: nil}
  @add_ev2 %Event{content: {:counter, {2}}, event_type: :added_belief, intents: nil}
  @add_ev3 %Event{content: {:counter, {3}}, event_type: :added_belief, intents: nil}

  @rule_head %RuleHead{context: %RuleContext{contexts: [], function: nil},
   trigger: %RuleTrigger{content: {:count, {}}, event_type: :added_goal}}

  describe "execute atomic plan executions" do
    test "if the plan is atomic, execute all of it" do
      plan = %Rule{atomic: true, body: [@add_bel1, @add_bel2, @add_bel3], head: @rule_head}

      intent = Intention.create(plan.body, E, [], plan)
      {events, new_intents, beliefs} = Reasoner.Intent.execute_intent([], intent)

      assert events == [@add_ev1, @add_ev2, @add_ev3]
      assert beliefs == [counter: {1}, counter: {2}, counter: {3}]
      assert new_intents == %Intention{executions: []}
    end

    test "if something fail in the middle report it and remove execution" do
      plan = %Rule{atomic: true, body: [@add_bel1, @query_bel, @add_bel2], head: @rule_head}

      intent = Intention.create(plan.body, E, [], plan)
      {:execution_error, new_intents, instruction, event} = Reasoner.Intent.execute_intent([], intent)

      assert instruction == %QueryBelief{name: :sell, params: [X]}
      assert event == E
      assert new_intents == %Intention{executions: []}
    end

    test "if the plan is atomic, execute all of it and return the rest of the intent" do
      plan = %Rule{atomic: true, body: [@add_bel1, @add_bel2, @add_bel3], head: @rule_head}

      intent = Intention.create([], E, [], P)
      intent = Intention.push(intent, plan.body, E, [], plan)

      {events, new_intents, beliefs} = Reasoner.Intent.execute_intent([], intent)

      assert events == [@add_ev1, @add_ev2, @add_ev3]
      assert beliefs == [counter: {1}, counter: {2}, counter: {3}]
      assert new_intents == %Intention{executions: [%IntentionExecution{bindings: [], event: E, instructions: [], plan: P}]}
    end
  end

end
