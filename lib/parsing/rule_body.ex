defmodule RuleBody do

  defstruct [:instructions]

  def parse([do: statements]) do
    do_parse(statements)
  end

  defp do_parse({:__block__, _, statements}) do
    Enum.map(statements, &do_parse_item/1)
  end

  defp do_parse(statements) when is_tuple(statements) do
   [do_parse_item(statements)]
  end

  defp do_parse_item({:!, _, [goal]} = statements) when is_tuple(statements) do
    case goal do
      {name, _, Elixir} -> {:goal, {name, []}}
      {name, _, params} -> {:goal, {name, params}}
      true -> :not_a_goal
    end
  end

  defp do_parse_item({statement, _, params} = statements) when is_tuple(statements) do
    {:belief, {statement, List.to_tuple(params)}}
  end


  # To delete

  def parse_beliefs([do: statements]) do
    statements |> do_parse_beliefs |> remove_non_beliefs
  end

  def parse_goals([do: statements]) do
    statements |> do_parse_goals |> remove_non_goals
  end

  # Parse Beliefs
  # -------------------
  defp do_parse_beliefs({:__block__, _, beliefs}) when is_list(beliefs) do
    Enum.map(beliefs, &do_parse_belief/1)
  end

  defp do_parse_beliefs(statements) when is_tuple(statements) do
   [do_parse_belief(statements)]
  end

  defp do_parse_belief({:!, _, _} = statements) when is_tuple(statements),
    do: :not_a_belief

  defp do_parse_belief({belief, _, params} = statements) when is_tuple(statements) do
    {belief, List.to_tuple(params)}
  end

  # Parse Beliefs
  # -------------------
  #
  defp do_parse_goals({:__block__, _, goals}) when is_list(goals) do
    Enum.map(goals, &do_parse_goal/1)
  end

  defp do_parse_goals(statements) when is_tuple(statements) do
   [do_parse_goal(statements)]
  end

  defp do_parse_goal({:!, _, [goal]}) do
    parse_single_goal(goal)
  end

  defp do_parse_goal(_) do
    :not_a_goal
  end

  defp parse_single_goal(goal) do
    case goal do
      {name, _, Elixir} -> {name, []}
      {name, _, params} -> {name, params}
      true -> :not_a_goal
    end
  end

  # Utils
  defp remove_non_beliefs(beliefs),
    do: Enum.filter(beliefs, fn x -> x != :not_a_belief end)

  defp remove_non_goals(goals),
    do: Enum.filter(goals, fn x -> x != :not_a_goal end)
end
