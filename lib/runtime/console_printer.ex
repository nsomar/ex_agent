defmodule Printer do
  @callback print(String.t) :: any
end

defmodule ConsolePrinter do
  @behaviour Printer
  def print(string) do
    IO.puts(string)
  end
end

defmodule ReturnPrinter do
  @behaviour Printer
  def print(string) do
    string
  end
end
