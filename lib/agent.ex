defmodule EXAgent do
  use GenServer

  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__)

      def create(name), do: EXAgent.create(name, initial_beliefs)
      def belief_base(agent), do: EXAgent.belief_base(agent)
    end
  end

  defmacro initial_beliefs(funcs) do
    res = ParsingUtils.parse_beliefs(funcs)
    quote do
      def initial_beliefs, do: unquote(res)
    end
  end

  defmacro agent_name(name) do
    quote do
      Process.whereis(__MODULE__) |> IO.inspect
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
