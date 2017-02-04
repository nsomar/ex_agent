defmodule AddBelief do
  defstruct [:b]

  def parse({:+, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    %AddBelief{
      b: {name, params |> CommonInstructionParser.parse_params |> List.to_tuple}
    }
  end
end
