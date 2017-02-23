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
end

