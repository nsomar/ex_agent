defmodule ExAgent.Mod do
  use GenServer
  require Logger

  ############################################################################
  # Using
  ############################################################################

  defmacro __using__(_) do
    quote do

      use ExAgent.Core

      import ExAgent
      import ExAgent.Core

      require Logger

      def create(name, linked \\ true), do: ExAgent.Mod.create_agent(__MODULE__, name, linked)
      def agent_name(name), do: ExAgent.Mod.agent_name(__MODULE__, name)
      def belief_base(ag), do: ExAgent.Mod.belief_base(ag)
      def plan_rules(ag), do: ExAgent.Mod.plan_rules(ag)
      def recovery_handlers(ag), do: ExAgent.Mod.recovery_handlers(ag)
      def message_handlers(ag), do: ExAgent.Mod.message_handlers(ag)
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

  def handle_call({:add_beliefs, new_beliefs}, _from, %{beliefs: beliefs} = state) do
    new_state = %{state| beliefs: beliefs ++ new_beliefs}
    {:reply, new_state, new_state}
  end

  def handle_call(:plan_rules, _from, %{plan_rules: rules} = state) do
    {:reply, rules, state}
  end

  def handle_call({:add_plan_rules, new_plan_rules}, _from, %{plan_rules: plan_rules} = state) do
    new_state = %{state | plan_rules: plan_rules ++ new_plan_rules}
    {:reply, new_plan_rules, new_state}
  end

  def handle_call(:recovery_handlers, _from, %{recovery_handlers: recovery_handlers} = state) do
    {:reply, recovery_handlers, state}
  end

  def handle_call({:add_recovery_handlers, new_recovery_handlers}, _from, %{recovery_handlers: recovery_handlers} = state) do
    new_state = %{state | recovery_handlers: recovery_handlers ++ new_recovery_handlers}
    {:reply, new_recovery_handlers, new_state}
  end

  def handle_call(:message_handlers, _from, %{message_handlers: message_handlers} = state) do
    {:reply, message_handlers, state}
  end

  def handle_call({:add_message_handlers, new_message_handlers}, _from, %{message_handlers: message_handlers} = state) do
    new_state = %{state | message_handlers: message_handlers ++ new_message_handlers}
    {:reply, new_message_handlers, new_state}
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
        Logger.info "New State\n#{inspect(new_state)}"
        ExAgent.Mod.run_loop(self())
        {:noreply, new_state}

      :recovery_added ->
        Logger.info "Agent State Recovered"
        ExAgent.Mod.run_loop(self())
        {:noreply, new_state}

      :no_recovery ->
        Logger.info "Agent State Failed. No Recovery Plan Found"
        {:noreply, new_state}

      :halt_agent ->
        Logger.info "Halting agent!!!"
        {:stop, 0, new_state}

       state ->
        Logger.info "Agent updated with state #{inspect(new_state)} for status #{inspect(state)}"
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
        ExAgent.Mod.run_loop(self())
        {:noreply, new_state}
    end
  end

   ############################################################################
  # Functions
  ############################################################################
  def create_agent(module, name, linked \\ true) do
    agent = ExAgent.Mod.create(agent_name(module, name), linked)

    AgentHelper.add_initial_beliefs(agent, module.initial_beliefs)
    AgentHelper.add_plan_rules(agent, module.plan_rules)
    AgentHelper.add_recovery_handlers(agent, module.recovery_handlers)
    AgentHelper.add_message_handlers(agent, module.message_handlers)
    AgentHelper.set_initial_as_intents(agent, module.initial)

    AgentHelper.add_responsibilities(agent, module.responsibilities)

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
      GenServer.start_link(ExAgent.Mod, state, name: name) |> elem(1)
    else
      GenServer.start(ExAgent.Mod, state, name: name) |> elem(1)
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

  def add_beliefs(agent, beliefs) do
    GenServer.call(agent, {:add_beliefs, beliefs})
  end

  def plan_rules(agent) do
    GenServer.call(agent, :plan_rules)
  end

  def add_plan_rules(agent, plan_rules) do
    GenServer.call(agent, {:add_plan_rules, plan_rules})
  end

  def recovery_handlers(agent) do
    GenServer.call(agent, :recovery_handlers)
  end

  def add_recovery_handlers(agent, recovery_handlers) do
    GenServer.call(agent, {:add_recovery_handlers, recovery_handlers})
  end

  def message_handlers(agent) do
    GenServer.call(agent, :message_handlers)
  end

  def add_message_handlers(agent, message_handlers) do
    GenServer.call(agent, {:add_message_handlers, message_handlers})
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
