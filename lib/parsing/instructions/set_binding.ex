defmodule SetBinding do
  defstruct [:name, :params]
  @type t :: %SetBinding{name: String.t, params: [any]}

  def parse({:=, _, [{_, _, [name]}, param]}) do
    %SetBinding{
      name: name,
      params: AstFunction.create(param)
    }
  end

  def execute(%SetBinding{name: name, params: params}, bindings) do
    res = AstFunction.perform(params, bindings)
    [{name, res}]
  end
end
