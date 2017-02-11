defmodule InternalActionExecutor do

  def execute(%InternalAction{name: :print}=internal_action, binding, printer) do
    params = InternalAction.params(internal_action, binding)
    params
    |> Enum.join("\n")
    |> printer.print
  end

end
