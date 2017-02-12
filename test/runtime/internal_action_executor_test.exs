defmodule InternalActionExecutorTest do
  use ExUnit.Case

  describe "print" do
    test "it execute print" do
      action = %InternalAction{name: :print, params: ["Hello World"]}
      assert InternalActionExecutor.execute(action, [], ReturnPrinter, X) == "Hello World"
    end

    test "it execute print with 2 params" do
      action = %InternalAction{name: :print, params: ["Hello World", " ..."]}
      assert InternalActionExecutor.execute(action, [], ReturnPrinter, X) == "Hello World\n ..."
    end

    test "it execute print with vars" do
      action = %InternalAction{name: :print,
   params: [%AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1,
     params: [:X]},
    %AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
     params: [:Y]}]}

      assert InternalActionExecutor.execute(action, [X: "Hello", Y: "World"], ReturnPrinter, X) == "Hello\nWorld"
    end

     test "it execute print with vars and functions" do
       action = %InternalAction{name: :print,
   params: [%AstFunction{ast: {:<>, [],
      [{:__aliases__, [], [:Word1]},
       {{:., [line: 11],
         [{:__aliases__, [counter: 0, line: 11], [:String]}, :upcase]}, [],
        [{:__aliases__, [], [:Word2]}]}]}, number_of_params: 2,
     params: [:Word1, :Word2]}]}

       assert InternalActionExecutor.execute(action, [Word1: "Hello", Word2: "World"], ReturnPrinter, X) == "HelloWORLD"
     end
  end

  describe "send" do
    test "it execute send with params" do
      action = %InternalAction{name: :send, params: ["agent1", :inform,
      %AstFunction{ast: {:echo, [], ["this"]}, number_of_params: 0, params: []}]}

      assert InternalActionExecutor.execute(action, [], ReturnPrinter, DebugMessageSender) == {"agent1", :inform, :echo, ["this"]}
    end

    test "it execute send with no params" do
      action = %InternalAction{name: :send, params: ["agent1", :inform,
      %AstFunction{ast: {:echo, [], []}, number_of_params: 0, params: []}]}

      assert InternalActionExecutor.execute(action, [], ReturnPrinter, DebugMessageSender) == {"agent1", :inform, :echo, []}
    end

    test "it execute send with no variables" do
      action = %InternalAction{name: :send, params: ["agent1", :inform,
      %AstFunction{ast: {:echo, [], [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]}, number_of_params: 2, params: [:X, :Y]}]}

      assert InternalActionExecutor.execute(action, [X: 1, Y: "aaa"], ReturnPrinter, DebugMessageSender) == {"agent1", :inform, :echo, [1, "aaa"]}
    end

    test "it execute send with function calls and variables" do
      action = %InternalAction{name: :send, params: ["agent1", :inform, %AstFunction{ast: {:echo, [], [{:__aliases__, [], [:X]}, {{:., [line: 382], [{:__aliases__, [counter: 0, line: 382], [:String]}, :upcase]}, [], [{:__aliases__, [], [:Y]}]}]}, number_of_params: 2, params: [:X, :Y]}]}

      assert InternalActionExecutor.execute(action, [X: 1, Y: "aaa"], ReturnPrinter, DebugMessageSender) == {"agent1", :inform, :echo, [1, "AAA"]}
    end

    test "it execute send with arithmatic" do
      action = %InternalAction{name: :send, params: ["agent1", :inform,
      %AstFunction{ast: {:echo, [], [{:+, [], [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]}]}, number_of_params: 2, params: [:X, :Y]}]}

      assert InternalActionExecutor.execute(action, [X: 1, Y: 10], ReturnPrinter, DebugMessageSender) == {"agent1", :inform, :echo, [11]}
    end

    test "it execute send with with informative as params" do
      action = %InternalAction{
        name: :send,
        params: [
          %AstFunction{ast: {:__aliases__, [], [:A]}, number_of_params: 1, params: [:A]},
          %AstFunction{ast: {:__aliases__, [], [:B]}, number_of_params: 1, params: [:B]},
          %AstFunction{ast: {:echo, [], [{:__aliases__, [], [:C]}]}, number_of_params: 1, params: [:C]}
        ]
      }

      assert InternalActionExecutor.execute(action, [A: "agent2", B: :request, C: "HELLO"], ReturnPrinter, DebugMessageSender)
      == {"agent2", :request, :echo, ["HELLO"]}
    end

    test "it execute send with with complex params" do
      action = %InternalAction{name: :send, params: [%AstFunction{ast: {{:., [line: 382], [{:__aliases__, [counter: 0, line: 382], [:String]}, :upcase]}, [], [{:__aliases__, [], [:A]}]}, number_of_params: 1, params: [:A]}, %AstFunction{ast: {:__aliases__, [], [:B]}, number_of_params: 1, params: [:B]}, %AstFunction{ast: {:echo, [], [{:__aliases__, [], [:C]}]}, number_of_params: 1, params: [:C]}]}

      assert InternalActionExecutor.execute(action, [A: "agent2", B: :request, C: "HELLO"], ReturnPrinter, DebugMessageSender)
      == {"AGENT2", :request, :echo, ["HELLO"]}
    end
  end

end
