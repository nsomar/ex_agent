defmodule AddBelief do
  defstruct [:name, :params]
  @type t :: %AddBelief{name: String.t, params: [any]}

  def parse({:+, _, [{name, _, params}]} = statements) when is_tuple(statements) do
    # IO.inspect(params)
    %AddBelief{
      name: name,
      params: AstFunction.create_from_list(params),
    } |> IO.inspect
  end

end
