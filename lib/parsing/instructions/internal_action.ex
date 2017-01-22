defmodule InternalAction do
  defstruct [:a]

  def parse({:&, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %InternalAction{
      a: {name, params |> CommonInstructionParser.parse_params |> List.to_tuple }
    }
  end

end
