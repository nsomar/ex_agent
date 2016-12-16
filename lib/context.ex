defmodule Context do
  defstruct [:tests, :function]

  def create(tests), do: %Context{tests: tests}
  def create(tests, func), do: %Context{tests: tests, function: func}
end
