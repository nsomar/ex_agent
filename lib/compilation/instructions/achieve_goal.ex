defmodule AchieveGoal do
  defstruct [:name, :params]
  @type t :: %AddBelief{name: String.t, params: [any]}

  def parse({:!, _, [goal]} = statements) when is_tuple(statements) do
    case goal do
      {name, _, Elixir} -> %AchieveGoal{name: name, params: []}
      {name, _, nil} ->  %AchieveGoal{name: name, params: []}
      {name, _, params} ->
        %AchieveGoal{
          name: name,
          params: CommonInstructionParser.parse_params(params),
        }
    end
  end

  def goal(%{name: name, params: params}, binding) do
    {
      name,
      CommonInstructionParser.prepared_params(params, binding)
    }
  end
end

defimpl EventContent, for: AchieveGoal do
  def content(goal, binding) do
    AchieveGoal.goal(goal, binding)
  end
end
