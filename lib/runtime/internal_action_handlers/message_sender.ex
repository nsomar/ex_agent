defmodule MessageSender do
  @callback send_message(String.t, atom, atom, [any]) :: any
end

defmodule DebugMessageSender do
  @behaviour MessageSender
  def send_message(recepient, performative, name, params) do
    {recepient, performative, name, params}
  end
end

defmodule ActualMessageSender do
  require Logger

  @behaviour MessageSender
  def send_message(recepient, performative, name, params) do
    case Process.whereis(recepient) do
      pid ->
        Logger.info """
        Sending Message
        To: #{inspect(recepient)}
        pid: #{inspect(pid)}
        Performative: #{inspect(performative)}
        Name: #{inspect(name)}
        Params: #{inspect(params)}
        """
        GenServer.cast(pid, {:message, {:message, {performative, name, params, self()}}})
        # send(pid, {:message, {performative, name, params, self()}})
      nil ->
        Logger.warn "Cannot find process with name #{inspect(recepient)}"
    end
  end

end
