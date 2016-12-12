defmodule BeliefUtil do
  def get_statements_matching_term(beleifs, term) do
    beleifs |>
    Enum.filter(fn bel -> get_belief_term(bel) == term end) |>
    Enum.map(fn bel -> get_beleif_statement(bel) end)
  end

  def get_belief_term({term, _}), do: term
  def get_belief_term(_), do: :no_term

  def get_beleif_statement({_, statement}), do: statement
  def get_beleif_statement(_), do: :no_term
end
