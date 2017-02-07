defmodule InternalActionExecutorTest do
  use ExUnit.Case

  test "it execute print" do
    action = %InternalAction{name: :print, params: ["Hello World"]}
    assert InternalActionExecutor.execute(action, nil, [], ReturnPrinter) == "Hello World"
  end

  test "it execute print with 2 params" do
    action = %InternalAction{name: :print, params: ["Hello World", " ..."]}
    assert InternalActionExecutor.execute(action, nil, [], ReturnPrinter) == "Hello World\n ..."
  end

  test "it execute print with vars" do
    action = %InternalAction{name: :print,
 params: [%AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1,
   params: [:X]},
  %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
   params: [:Y]}]}

    assert InternalActionExecutor.execute(action, nil, [X: "Hello", Y: "World"], ReturnPrinter) == "Hello\nWorld"
  end

   test "it execute print with vars and functions" do
     action = %InternalAction{name: :print,
 params: [%AstFunction{ast: {:<>, [],
    [{:__aliases__, [], [:Word1]},
     {{:., [line: 11],
       [{:__aliases__, [counter: 0, line: 11], [:String]}, :upcase]}, [],
      [{:__aliases__, [], [:Word2]}]}]}, number_of_params: 2,
   params: [:Word1, :Word2]}]}

     assert InternalActionExecutor.execute(action, nil, [Word1: "Hello", Word2: "World"], ReturnPrinter) == "HelloWORLD"
   end

end
