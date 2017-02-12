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

      Module.register_attribute __MODULE__, :rules,
      accumulate: true, persist: false

      def create(name), do: ExAgent.create(__MODULE__, name)
      def belief_base(ag), do: ExAgent.belief_base(ag)
      def plan_rules(ag), do: ExAgent.plan_rules(ag)

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
    r = Rule.parse(head, body) |> Macro.escape

    quote bind_quoted: [r: r] do
      @rules r
    end
  end

  defmacro start do
    quote do
      @started true
      def initial, do: @initial
      def initial_beliefs, do: @initial_beliefs
      def plan_rules, do: @rules |> Enum.reverse
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

  def handle_call({:add_plan, new_plan}, _from, %{plan_rules: rules} = state) do
    new_plans = rules ++ [new_plan]
    {:reply, new_plans, Map.put(state, :plan_rules, new_plans)}
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

  def handle_cast(:run_loop, state) do
    new_state = Reasoner.reason(state)
    {:noreply, new_state}
  end

  ############################################################################
  # Functions
  ############################################################################
  def create(module, name) do
    agent = ExAgent.create(:"#{module}.#{name}")

    AgentHelper.add_initial_beliefs(agent, module.initial_beliefs)
    AgentHelper.add_plan_rules(agent, module.plan_rules)
    AgentHelper.set_initial_as_intents(agent, module.initial)

    Logger.info fn -> "\nAgent #{name} creates\nRules:\n#{inspect(module.plan_rules)}" end

    agent
  end

  def create(name) when is_atom(name) do
    state = %AgentState{beliefs: [], plan_rules: [], intents: [], events: [], name: name, module: __MODULE__}
    GenServer.start_link(__MODULE__, state, name: name) |> elem(1)
  end

  def run_loop(agent) do
    GenServer.cast(agent, :run_loop)
    run_loop(agent)
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

  def add_plan_rule(agent, plan) do
    GenServer.call(agent, {:add_plan, plan})
  end

  def plan_rules(agent) do
    GenServer.call(agent, :plan_rules)
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
end
