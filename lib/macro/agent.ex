defmodule EXAgent do
  use GenServer
  require Logger

  defmacro __using__(_) do
    quote do

      import unquote(__MODULE__)
      require Logger

      @initial []
      @started false
      @after_compile __MODULE__

      Module.register_attribute __MODULE__, :rules,
      accumulate: true, persist: false

      def create(name) do
        agent = EXAgent.create(:"#{__MODULE__}.#{name}")
        EXAgent.add_plan_rules(agent, __MODULE__.plan_rules)

        Logger.info fn -> "\nAgent #{name} creates\nRules:\n#{inspect(__MODULE__.plan_rules)}" end

        agent
      end

      def belief_base(ag), do: EXAgent.belief_base(ag)
      def plan_rules(ag), do: EXAgent.plan_rules(ag)

      defmacro __after_compile__(_, _) do
        quote do
          unless @started do
            CompilerHelpers.print_aget_not_started_message(__MODULE__)
          end
        end
      end
    end
  end

  defmacro initialize(funcs) do
    quote bind_quoted: [funcs: funcs |> Macro.escape] do
      @initial funcs |> RuleBody.parse
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
      def plan_rules, do: @rules |> Enum.reverse
    end
  end

  def handle_call(:belief_base, _from, %{beliefs: beliefs} = state) do
    {:reply, beliefs, state}
  end

  def handle_call(:plan_rules, _from, %{plan_rules: rules} = state) do
    {:reply, rules, state}
  end

  def handle_call({:add_plan, new_plan}, _from, %{plan_rules: rules} = state) do
    new_plans = rules ++ [new_plan]
    {:reply, new_plans, Map.put(state, :plan_rules, new_plans)}
  end

  def create(name) when is_atom(name) do
    {:ok, bb} = BeliefBase.create([])
    state = %EXAgentState{beliefs: bb, plan_rules: []}
    GenServer.start_link(__MODULE__, state, name: name) |> elem(1)
  end

  def belief_base(agent) do
    GenServer.call(agent, :belief_base)
  end

  def add_plan_rules(agent, plans) do
    plans
    |> Enum.map(fn rule ->
      EXAgent.add_plan_rule(agent, rule)
    end)
  end

  def add_plan_rule(agent, plan) do
    GenServer.call(agent, {:add_plan, plan})
  end

  def plan_rules(agent) do
    GenServer.call(agent, :plan_rules)
  end

end
