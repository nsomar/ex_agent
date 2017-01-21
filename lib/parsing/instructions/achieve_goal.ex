defmodule AchieveGoal do
  defstruct [:g]

  def parse({:!, _, [goal]} = statements) when is_tuple(statements) do
    case goal do
      {name, _, Elixir} -> %AchieveGoal{g: {name, []}}
      {name, _, nil} -> %AchieveGoal{g: {name, []}}
      {name, _, params} -> %AchieveGoal{g: {name, params |> CommonInstructionParser.parse_params}}
      true -> :not_a_goal
    end
  end

end
