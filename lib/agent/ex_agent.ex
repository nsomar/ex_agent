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

        start()
      end
    end
  end

  defmacro defrole({_, _, [name]}, [do: body]) do
    quote do

      defmodule :"Elixir.#{Atom.to_string(unquote(name))}" do
        use ExAgent.Core
        require Logger

        unquote(body)

        start()
      end
    end
  end

  @spec send_message(atom, String.t, atom, atom, [any]) :: any
  def send_message(module, agent_name, performative, name, params) do
    agent_full_name = module.agent_name(agent_name)
    ActualMessageSender.send_message(agent_full_name, performative, name, params)
  end

  @spec send_message(String.t, atom, atom, [any]) :: any
  def send_message(recepient, performative, name, params) do
    ActualMessageSender.send_message(recepient, performative, name, params)
  end

  @spec start_agent(atom, String.t, boolean) :: any
  def start_agent(module, name, linked \\ true) do
    ExAgent.Creator.start_agent(module, name, linked)
  end

  def stop_agent(module, name) do
    case ExAgent.Registry.find(module, name) do
      :not_found -> true
      pid ->
        GenServer.cast(pid, :halt_agent)
    end
  end

end

