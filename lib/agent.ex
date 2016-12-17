defmodule EXAgent do
  use GenServer

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      def create(name), do: EXAgent.create(name, initial_beliefs)
      def belief_base(agent), do: EXAgent.belief_base(agent)
    end
  end

  defmacro initialize(funcs) do
    beliefs = funcs |> Parsing.Macro.parse_beliefs |> Macro.escape
    goals = funcs |> Parsing.Macro.parse_beliefs |> Macro.escape
    quote do
      def initial_beliefs, do: unquote(beliefs)
      def initial_goals, do: unquote(goals)
    end
  end

  defmacro on(trigger, context, function) do
    IO.inspect {context}
    quote do
      1
    end
  end

  def handle_call(:belief_base, _from, %{beliefs: beliefs} = state) do
    {:reply, beliefs, state}
  end

  def create do
    create(__MODULE__)
  end

  def create(name, beliefs_from_macro) when is_atom(name) do
    agent = EXAgent.create(name)
    belief_base = EXAgent.belief_base(agent)
    Enum.map(beliefs_from_macro, fn b ->
      BeliefBase.add_belief(belief_base, b)
    end)

    agent
  end

  def create(name) when is_atom(name) do
    {:ok, bb} = BeliefBase.create([])
    state = %EXAgentState{beliefs: bb}
    GenServer.start_link(__MODULE__, state, name: name) |> elem(1)
  end

  def belief_base(agent) do
    GenServer.call(agent, :belief_base)
  end

end
