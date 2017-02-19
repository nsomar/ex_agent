defmodule InternalActionExecutor do

  def execute(%InternalAction{name: :print}=internal_action, binding, printer, _) do
    params = InternalAction.params(internal_action, binding)
    params = params
    |> Enum.join("\n")
    |> printer.print

    {:action, params}
  end

  def execute(%InternalAction{name: :exit}, _, _, _) do
    {:halt_agent, false}
  end

  def execute(%InternalAction{name: :send, params: params}, binding, _, sender) do
    [to, performative, %{ast: {message_name, [], message_params}}] = params

    prepared_to = CommonInstructionParser.prepared_param(to, binding)
    prepared_performative = CommonInstructionParser.prepared_param(performative, binding)

    prepared_params = peform_ast_function_for_params(message_params, [], binding)
    result = sender.send_message(prepared_to, prepared_performative, message_name, prepared_params)

    {:action, result}
  end

  def execute(_, _, _, _) do
    {:no_op, false}
  end

  defp peform_ast_function_for_params(message_params, function_params, binding) do
    message_params
    |> Enum.map(fn ast -> AstFunction.perform(ast, function_params, binding) end)
  end

end
