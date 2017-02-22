defmodule ExAgent do
  require Logger

  defmacro __using__(_) do
    quote do
      import ExAgent
      require Logger
    end
  end

  defmacro defagent({_, _, [name]}, [do: body]) do
    quote do

      defmodule :"Elixir.#{Atom.to_string(unquote(name))}" do
        use ExAgent.Mod
        require Logger

        unquote(body)

        start
      end
    end
  end

  defmacro defresp({_, _, [name]}, [do: body]) do
    quote do

      defmodule :"Elixir.#{Atom.to_string(unquote(name))}" do
        use ExAgent.Core
        require Logger

        unquote(body)

        start
      end
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

