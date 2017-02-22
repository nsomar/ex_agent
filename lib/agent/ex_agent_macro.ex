defmodule ExAgent.Mod do

  defmacro __using__(_) do
    quote do
      import ExAgent.Mod
      require Logger
    end
  end

  defmacro defagent({_, _, [name]}, [do: body]) do
    quote do

      defmodule :"Elixir.#{Atom.to_string(unquote(name))}" do
        use ExAgent

        unquote(body)

        start
      end
    end
  end

end

