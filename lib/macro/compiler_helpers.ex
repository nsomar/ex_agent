defmodule CompilerHelpers do
  def print_aget_not_started_message(mod) do
    IO.puts """
    Agent defined in module #{mod} not started.
    Make sure to call start as the last instruction in the agent

    Example:

    defmodule MyAgent do

      initialize do
        ...
      end

      rule (+...) when ... test ... do

      end

      start
    end
    """
  end
end
