defmodule EXAgent do
  use GenServer

  defmacro __using__(_) do
    quote do

      import unquote(__MODULE__)
      @server EXAgent.create(__MODULE__)

      def agent, do: @server
      def belief_base, do: EXAgent.belief_base(@server)
      def plan_rules, do: EXAgent.plan_rules(@server)
      def a, do: EXAgent.a(@server)
    end
  end

  defmacro initialize(funcs) do
    initial = funcs |> RuleBody.parse |> Macro.escape

    quote do
      def initial, do: unquote(initial)
    end
  end

  # on(+cost(X, Y), money(Z) && nice(X) && not want_to_buy(X) &&
  #        fn x, y, z -> x == y end) do
  defmacro on(trigger, context, function) do
    quote do
      1
    end
  end

  # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro rule(head, body) do
    r = Rule.parse(head, body) |> Macro.escape

    quote do
      EXAgent.add_plan_rule(@server, unquote(r))
    end
  end

  def handle_call(:belief_base, _from, %{beliefs: beliefs} = state) do
    {:reply, beliefs, state}
  end

  def handle_call(:a, _from, state) do
    {:reply, state, state}
  end

  def handle_call(:plan_rules, _from, %{plan_rules: plan_rules} = state) do
    {:reply, plan_rules, state}
  end

  def handle_call({:add_plan, new_plan}, _from, %{plan_rules: plan_rules} = state) do
    new_plans = plan_rules ++ [new_plan]
    {:reply, new_plans, Map.put(state, :plan_rules, new_plans)}
  end

  def create do
    create(__MODULE__)
  end

  def create(name, beliefs_from_macro) when is_atom(name) do
    agent = EXAgent.create(name)
    belief_base = EXAgent.belief_base(agent)

    # Start doing stuff in the initial

    agent
  end

  def create(name) when is_atom(name) do
    {:ok, bb} = BeliefBase.create([])
    state = %EXAgentState{beliefs: bb, plan_rules: []}
    IO.inspect("ssss #{inspect(state)}")
    IO.inspect("name #{name}")
    GenServer.start_link(__MODULE__, state, name: name) |> elem(1)
  end

  def belief_base(agent) do
    GenServer.call(agent, :belief_base)
  end

  def add_plan_rule(agent, plan) do
    GenServer.call(agent, {:add_plan, plan})
  end

  def plan_rules(agent) do
    GenServer.call(agent, :plan_rules)
  end

  def a(agent) do
    GenServer.call(agent, :a)
  end

end
