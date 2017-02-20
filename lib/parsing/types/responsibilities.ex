defmodule Responsibility do
  defstruct [:responsibilities]
  @type t :: %Responsibility{responsibilities: any}

  def parse([do: responsibilities]) do
    responsibilities = do_parse(responsibilities)
    |> Enum.uniq
    %Responsibility{responsibilities: responsibilities}
  end

  def initial_beliefs(responsibility) do
    get_type(responsibility, :initial_beliefs)
  end

  def plan_rules(responsibility) do
    get_type(responsibility, :plan_rules)
  end

  def message_handlers(responsibility) do
    get_type(responsibility, :message_handlers)
  end

  def recovery_handlers(responsibility) do
    get_type(responsibility, :recovery_handlers)
  end

  defp get_type([], _), do: []
  defp get_type(%{responsibilities: responsibilities}, type) do
    responsibilities
    |> Enum.map(fn item ->
      module_name(item) |> apply(type, [])
    end)
    |> List.flatten
    |> Enum.uniq
  end


  defp do_parse(nil) do
    []
  end

  defp do_parse({:__block__, _, statements}) do
    statements
    |> Enum.map(&do_parse_item/1)
  end

  defp do_parse(statements) when is_tuple(statements) do
   [do_parse_item(statements)]
  end

  defp do_parse_item({:__aliases__, _, [name]}) do
    {:ok, name} = check_responsiblity(name)
    name
  end

  defp check_responsiblity(responsibility) do
    name = module_name(responsibility)

    with {:module, _} <- Code.ensure_loaded(name),
         true <- function_exported?(name, :initial, 0),
         true <- function_exported?(name, :plan_rules, 0) do
      {:ok, responsibility}
    else
      {:error, _} -> {:error, "Module not exits #{responsibility}"}
    end
  end

  defp module_name(responsibility), do: :"Elixir.#{responsibility}"
end
