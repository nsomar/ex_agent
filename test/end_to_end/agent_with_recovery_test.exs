defmodule AgentWithRecoveryTest do
  use ExUnit.Case

  describe "without recovery" do
    defmodule AgentWithTestRecovery do
      use ExAgent
      # use Protocols.only(:asdsa, :aaaa)

      rule (+bel1) do
        query(price(1))
      end

      rule (+bel2(X)) do
        query(price(X))
      end

      rule (+bel3) do
        query(price)
      end

      start
    end

    test "it errors with constant query" do
      ag = AgentWithTestRecovery.create("agent1")

      goal = %AddBelief{name: :bel1, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :no_recovery
      assert state.events == []
      assert state.intents == []
    end

    test "it errors with variable query" do
      ag = AgentWithTestRecovery.create("agent1")

      goal = %AddBelief{name: :bel2, params: [10]}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :no_recovery
      assert state.events == []
      assert state.intents == []
    end

    test "it errors with no param query" do
      ag = AgentWithTestRecovery.create("agent1")

      goal = %AddBelief{name: :bel3, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :no_recovery
      assert state.events == []
      assert state.intents == []
    end
  end

  describe "with recovery" do
    defmodule AgentWithTestRecovery2 do
      use ExAgent
      # use Protocols.only(:asdsa, :aaaa)

      rule (+bel1) do
        query(price(1))
      end

      recovery (+bel1) do
        +recovered
      end

      rule (+bel2(X)) do
        query(price(X))
      end

      recovery (+bel2(X)) do
        +recovered(X)
      end

      rule (+bel3) do
        query(price)
      end

      recovery (+bel3) do
        +recovered
      end

      start
    end

    test "it errors with constant query" do
      ag = AgentWithTestRecovery2.create("agent1")

      goal = %AddBelief{name: :bel1, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :recovery_added
      assert state.events == []
      assert state.intents == [%Intention{bindings: [], event: %Event{content: {:bel1, {}}, event_type: :added_belief, intents: nil}, instructions: [%AddBelief{name: :recovered, params: []}], plan: %Rule{body: [%AddBelief{name: :recovered, params: []}], head: %RuleHead{context: %RuleContext{contexts: [], function: nil}, trigger: %RuleTrigger{content: {:bel1, {}}, event_type: :added_belief}}}}]

      {update, state} = Reasoner.reason(state)
      assert state.beliefs == [recovered: {}]
    end

    test "it errors with variable query" do
      ag = AgentWithTestRecovery2.create("agent1")

      goal = %AddBelief{name: :bel2, params: ["HELLO"]}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :recovery_added
      assert state.events == []
      assert state.intents == [%Intention{bindings: [X: "HELLO"], event: %Event{event_type: :added_belief, intents: nil, content: {:bel2, {"HELLO"}}}, instructions: [%AddBelief{name: :recovered, params: [%AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}]}], plan: %Rule{body: [%AddBelief{name: :recovered, params: [%AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}]}], head: %RuleHead{context: %RuleContext{contexts: [], function: nil}, trigger: %RuleTrigger{event_type: :added_belief, content: {:bel2, {:X}}}}}}]

      {update, state} = Reasoner.reason(state)
      assert state.beliefs == [recovered: {"HELLO"}]
    end

    test "it errors with no variable query" do
      ag = AgentWithTestRecovery2.create("agent1")

      goal = %AddBelief{name: :bel3, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :recovery_added
      assert state.events == []
      assert state.intents == [%Intention{bindings: [], instructions: [%AddBelief{name: :recovered, params: []}], event: %Event{event_type: :added_belief, intents: nil, content: {:bel3, {}}}, plan: %Rule{body: [%AddBelief{name: :recovered, params: []}], head: %RuleHead{context: %RuleContext{contexts: [], function: nil}, trigger: %RuleTrigger{event_type: :added_belief, content: {:bel3, {}}}}}}]

      {update, state} = Reasoner.reason(state)
      assert state.beliefs == [recovered: {}]
    end

  end

  describe "with failed recovery" do
    defmodule AgentWithTestRecovery3 do
      use ExAgent
      # use Protocols.only(:asdsa, :aaaa)

      rule (+bel1) do
        query(price(1))
      end

      recovery (+bel1) do
        &exit
      end

      start
    end

    test "it does not recover a failed recovery" do
      ag = AgentWithTestRecovery3.create("agent1")

      goal = %AddBelief{name: :bel1, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}

      {update, state} = Reasoner.reason(state)
      assert update == :recovery_added

      state = Reasoner.reason(state)
      assert state |> elem(0) == :halt_agent
    end

    test "running the agent" do
      ag = AgentWithTestRecovery3.create("agent1", false)

      goal = %AddBelief{name: :bel1, params: []}
      event = Event.from_instruction(goal, [])

      state = ExAgent.agent_state(ag)
      state = %{state | events: [event]}
      ExAgent.set_agent_state(ag, state)

      ExAgent.agent_state(ag)

      # ExAgent.stop_agent(ag)
      ExAgent.run_loop(ag)
      Process.sleep(1000)
      assert Process.alive?(ag) == false
    end
  end

end
