defmodule CommonBeliefParser do

  defmacro __using__(_) do
    quote do
      def belief(%{name: name, params: params}, binding) do
        {
          name,
          CommonInstructionParser.prepared_params(params, binding)
        }
      end
    end
  end

end
