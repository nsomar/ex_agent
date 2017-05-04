defmodule RuleBody do

  defstruct [:instructions]
  @type t :: %RuleBody{instructions: tuple}

  def parse([do: statements]) do
    do_parse(statements)
  end

  defp do_parse(nil) do
    []
  end

  defp do_parse({:__block__, _, statements}) do
    Enum.map(statements, &do_parse_item/1)
  end

  defp do_parse(statements) when is_tuple(statements) do
   [do_parse_item(statements)]
  end

  defp do_parse_item({:!, _, _} = statements) when is_tuple(statements) do
    AchieveGoal.parse(statements)
  end

  defp do_parse_item({:-, _, [{:+, _, _}]} = statements) when is_tuple(statements) do
    ReplaceBelief.parse(statements)
  end

  defp do_parse_item({:+, _, _} = statements) when is_tuple(statements) do
    AddBelief.parse(statements)
  end

  defp do_parse_item({:-, _, _} = statements) when is_tuple(statements) do
    RemoveBelief.parse(statements)
  end

  defp do_parse_item({:query, _, _} = statements) when is_tuple(statements) do
    QueryBelief.parse(statements)
  end

  defp do_parse_item({:all, _, _} = statements) when is_tuple(statements) do
    AllBeliefs.parse(statements)
  end

  defp do_parse_item({:&, _, _} = statements) when is_tuple(statements) do
    InternalAction.parse(statements)
  end

  defp do_parse_item({:=, _, _} = statements) when is_tuple(statements) do
    SetBinding.parse(statements)
  end

end
