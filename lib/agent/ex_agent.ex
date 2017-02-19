defmodule ExAgent do
  use GenServer
  require Logger

  ############################################################################
  # Using
  ############################################################################

  defmacro __using__(_) do
    quote do

      import unquote(__MODULE__)
      require Logger

      @initial []
      @initial_beliefs []
      @started false
      @after_compile __MODULE__

      Module.register_attribute __MODULE__, :rule_handlers,
      accumulate: true, persist: false

      Module.register_attribute __MODULE__, :message_handlers,
      accumulate: true, persist: false

      Module.register_attribute __MODULE__, :recovery_handlers,
      accumulate: true, persist: false

      def create(name, linked \\ true), do: ExAgent.create_agent(__MODULE__, name, linked)
      def agent_name(name), do: ExAgent.agent_name(__MODULE__, name)
      def belief_base(ag), do: ExAgent.belief_base(ag)
      def plan_rules(ag), do: ExAgent.plan_rules(ag)
      def recovery_handlers(ag), do: ExAgent.recovery_handlers(ag)
      def message_handlers(ag), do: ExAgent.message_handlers(ag)

      defmacro __after_compile__(_, _) do
        quote do
          unless @started do
            CompilerHelpers.print_aget_not_started_message(__MODULE__)
          end
        end
      end
    end
  end

  ############################################################################
  # Macros
  ############################################################################

  defmacro initialize(funcs) do
    quote bind_quoted: [funcs: funcs |> Macro.escape] do
      @initial funcs |> RuleBody.parse
    end
  end

  defmacro initial_beliefs(funcs) do
    quote bind_quoted: [funcs: funcs |> Macro.escape] do
      @initial_beliefs funcs |> InitialBeliefs.parse
    end
  end

  # on(+cost(X, Y), money(Z) && nice(X) && not want_to_buy(X) &&
  #        fn x, y, z -> x == y end) do
  defmacro on(_, _, _) do
    quote do
      1
    end
  end

  # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro rule(head, body) do
    r = Rule.parse(head, body, false) |> Macro.escape

    quote bind_quoted: [r: r] do
      @rule_handlers r
    end
  end

  # atomic_rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro atomic_rule(head, body) do
    r = Rule.parse(head, body, true) |> Macro.escape

    quote bind_quoted: [r: r] do
      @rule_handlers r
    end
  end

  # recover (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro recovery(head, body) do
    r = Rule.parse(head, body) |> Macro.escape

    quote bind_quoted: [r: r] do
      @recovery_handlers r
    end
  end

  # message (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro message(performative, sender, head, body) do
    r = MessageHandler.parse(performative, sender, head, body) |> Macro.escape

    quote bind_quoted: [r: r] do
      @message_handlers r
    end
  end

  defmacro atomic_message(performative, sender, head, body) do
    r = MessageHandler.parse(performative, sender, head, body, true) |> Macro.escape

    quote bind_quoted: [r: r] do
      @message_handlers r
    end
  end

  defmacro start do
    quote do
      @started true
      def initial, do: @initial
      def initial_beliefs, do: @initial_beliefs
      def plan_rules, do: @rule_handlers |> Enum.reverse
      def recovery_handlers, do: @recovery_handlers |> Enum.reverse
      def message_handlers, do: @message_handlers |> Enum.reverse
    end
  end

  ############################################################################
  # GenServer
  ############################################################################

  def handle_call(:beliefs, _from, %{beliefs: beliefs} = state) do
    {:reply, beliefs, state}
  end

  def handle_call({:add_belief, belief}, _from, %{beliefs: beliefs} = state) do
    {res, new_beliefs} = BeliefBase.add_belief(beliefs, belief)
    new_state = %{state| beliefs: new_beliefs}
    {:reply, {res, new_beliefs}, new_state}
  end

  def handle_call({:remove_belief, belief}, _from, %{beliefs: beliefs} = state) do
    {res, new_beliefs} = BeliefBase.remove_belief(beliefs, belief)
    new_state = %{state| beliefs: new_beliefs}
    {:reply, {res, new_beliefs}, new_state}
  end

  def handle_call({:set_beliefs, new_beliefs}, _from, state) do
    new_state = %{state| beliefs: new_beliefs}
    {:reply, new_state, new_state}
  end

  def handle_call(:plan_rules, _from, %{plan_rules: rules} = state) do
    {:reply, rules, state}
  end

  def handle_call({:set_plan_rules, plan_rules}, _from, state) do
    new_state = %{state | plan_rules: plan_rules}
    {:reply, plan_rules, new_state}
  end

  def handle_call(:recovery_handlers, _from, %{recovery_handlers: recovery_handlers} = state) do
    {:reply, recovery_handlers, state}
  end

  def handle_call({:set_recovery_handlers, recovery_handlers}, _from, state) do
    new_state = %{state | recovery_handlers: recovery_handlers}
    {:reply, recovery_handlers, new_state}
  end

  def handle_call(:message_handlers, _from, %{message_handlers: message_handlers} = state) do
    {:reply, message_handlers, state}
  end

  def handle_call({:set_message_handlers, message_handlers}, _from, state) do
    new_state = %{state | message_handlers: message_handlers}
    {:reply, message_handlers, new_state}
  end

  def handle_call(:events, _from, %{events: events} = state) do
    {:reply, events, state}
  end

  def handle_call({:add_event, new_event}, _from, %{events: events} = state) do
    new_events = events ++ [new_event]
    {:reply, new_events, Map.put(state, :events, new_events)}
  end

  def handle_call({:set_events, events}, _from, state) do
    {:reply, events, Map.put(state, :events, events)}
  end

  def handle_call(:intents, _from, %{intents: intents} = state) do
    {:reply, intents, state}
  end

  def handle_call({:add_intent, new_intent}, _from, %{intents: intents} = state) do
    new_intents = intents ++ [new_intent]
    {:reply, new_intents, Map.put(state, :intents, new_intents)}
  end

  def handle_call({:set_intents, intents}, _from, state) do
    {:reply, intents, Map.put(state, :intents, intents)}
  end

  def handle_call(:agent_state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:set_agent_state, new_state}, _from, _state) do
    {:reply, new_state, new_state}
  end

  def handle_call(:messages, _from, %{messages: messages}=state) do
    {:reply, messages, state}
  end

  def handle_cast(:run_loop, state) do
    {update, new_state} = Reasoner.reason(state)

    case update do
      :changed ->
        Logger.info "Agent State Changed"
        ExAgent.run_loop(self())
        {:noreply, new_state}

      :recovery_added ->
        Logger.info "Agent State Recovered"
        ExAgent.run_loop(self())
        {:noreply, new_state}

      :no_recovery ->
        Logger.info "Agent State Failed. No Recovery Plan Found"
        {:noreply, new_state}

      :halt_agent ->
        Logger.info "Halting agent!!!"
        {:stop, 0, new_state}

       state ->
        Logger.info "Agent updated with state #{inspect(state)}"
        {:noreply, new_state}
    end
  end

  def handle_cast({:message, msg}, %{messages: messages}=state) do
    case Message.parse(msg) do
      :not_a_message ->
        {:noreply, state}
      msg ->
        new_state = %{state | messages: [msg| messages]}
        Logger.info "New message received #{inspect(msg)}"
        ExAgent.run_loop(self())
        {:noreply, new_state}
    end
  end

  ############################################################################
  # Functions
  ############################################################################
  def create_agent(module, name, linked \\ true) do
    agent = ExAgent.create(agent_name(module, name), linked)

    AgentHelper.add_initial_beliefs(agent, module.initial_beliefs)
    AgentHelper.add_plan_rules(agent, module.plan_rules)
    AgentHelper.add_recovery_handlers(agent, module.recovery_handlers)
    AgentHelper.add_message_handlers(agent, module.message_handlers)
    AgentHelper.set_initial_as_intents(agent, module.initial)

    Logger.info fn -> "\nAgent #{name} creates\nRules:\n#{inspect(module.plan_rules)}" end

    agent
  end

  def create(name, linked \\ true) when is_atom(name) do
    state = %AgentState{
      beliefs: [], plan_rules: [], intents: [], events: [],
      name: name, module: __MODULE__, message_handlers: [],
      messages: [], recovery_handlers: []
    }

    if linked do
      GenServer.start_link(__MODULE__, state, name: name) |> elem(1)
    else
      GenServer.start(__MODULE__, state, name: name) |> elem(1)
    end
  end

  def agent_name(module, name), do: :"#{module}.#{name}"

  def run_loop(agent) do
    GenServer.cast(agent, :run_loop)
  end

  def beliefs(agent) do
    GenServer.call(agent, :beliefs)
  end

  def add_belief(agent, belief) do
    GenServer.call(agent, {:add_belief, belief})
  end

  def remove_belief(agent, belief) do
    GenServer.call(agent, {:remove_belief, belief})
  end

  def set_beliefs(agent, beliefs) do
    GenServer.call(agent, {:set_beliefs, beliefs})
  end

  def plan_rules(agent) do
    GenServer.call(agent, :plan_rules)
  end

  def set_plan_rules(agent, plan_rules) do
    GenServer.call(agent, {:set_plan_rules, plan_rules})
  end

  def recovery_handlers(agent) do
    GenServer.call(agent, :recovery_handlers)
  end

  def set_recovery_handlers(agent, recovery_handlers) do
    GenServer.call(agent, {:set_recovery_handlers, recovery_handlers})
  end

  def message_handlers(agent) do
    GenServer.call(agent, :message_handlers)
  end

  def set_message_handlers(agent, message_handlers) do
    GenServer.call(agent, {:set_message_handlers, message_handlers})
  end

  def events(agent) do
    GenServer.call(agent, :events)
  end

  def add_event(agent, event) do
    GenServer.call(agent, {:add_event, event})
  end

  def set_events(agent, events) do
    GenServer.call(agent, {:set_event, events})
  end

  def intents(agent) do
    GenServer.call(agent, :intents)
  end

  def add_intent(agent, intent) do
    GenServer.call(agent, {:add_intent, intent})
  end

  def set_intents(agent, intents) do
    GenServer.call(agent, {:set_intents, intents})
  end

  def agent_state(agent) do
    GenServer.call(agent, :agent_state)
  end

  def set_agent_state(agent, new_state) do
    GenServer.call(agent, {:set_agent_state, new_state})
  end

  def messages(agent) do
    GenServer.call(agent, :messages)
  end
end
