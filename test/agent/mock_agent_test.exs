defmodule MockAgentTest do
  use ExUnit.Case

  describe "Mock Agent With Initial Beleifs" do

    test "it has initial beliefs" do
      defmodule MockAgentWInitialB1 do
        use ExAgent.Mod

        initial_beliefs do
          cost(:car, System.compiled_endianness())
          cost(:iphone, 500)
          color(:car, :red)
        end

        initialize do end
        start()
      end

      assert MockAgentWInitialB1.initial_beliefs ==
        [
          %Belief{name: :cost, params: [:car, %AstFunction{ast: {{:., [line: 11], [{:__aliases__, [counter: 0, line: 11], [:System]}, :compiled_endianness]}, [], []}, number_of_params: 0, params: []}]},
          %Belief{name: :cost, params: [:iphone, 500]},
          %Belief{name: :color, params: [:car, :red]}
        ]
    end

    test "it parses initial beliefs" do
      defmodule MockAgentWInitialB2 do
        use ExAgent.Mod

        initial_beliefs do
          cost(:car, System.compiled_endianness())
          cost(:iphone, 500)
          color(:car, :red)
        end

        initialize do end
        start()
      end

      ag = MockAgentWInitialB2.create("ag")
      beliefs = ag |> ExAgent.Mod.beliefs
      assert beliefs ==
      [cost: {:car, :little}, cost: {:iphone, 500}, color: {:car, :red}]
    end

    test "it parses initial beliefs 2" do
      defmodule MockAgentWInitialB3 do
        use ExAgent.Mod

        initial_beliefs do
          cost(:car, System.compiled_endianness())
          cost(:iphone, 500)
          color(:car, :red)
        end

        initialize do end
        start()
      end

      ag = ExAgent.Mod.create_agent(MockAgentWInitialB3, "ag")
      beliefs = ag |> ExAgent.Mod.beliefs
      assert beliefs ==
      [cost: {:car, :little}, cost: {:iphone, 500}, color: {:car, :red}]
    end
  end

  describe "Mock Agent With Beleifs" do
    defmodule MockAgentWB do
      use ExAgent.Mod

      initialize do
        +cost(:car, 10000)
        +cost(:iphone, 500)
        +color(:car, :red)
        +color(:iphone, :black)
        +is(:man, :omar)
      end

      start()
    end

    test "it captures beleifs in initialize" do
      assert MockAgentWB.initial ==
        [
          %AddBelief{name: :cost, params: [:car, 10000]},
          %AddBelief{name: :cost, params: [:iphone, 500]},
          %AddBelief{name: :color, params: [:car, :red]},
          %AddBelief{name: :color, params: [:iphone, :black]},
          %AddBelief{name: :is, params: [:man, :omar]}
        ]
    end

    test "it has a belief base with the initial beliefs" do
      ag = MockAgentWB.create("ag1")
      assert ExAgent.Mod.beliefs(ag) == []
    end
  end

  describe "Mock Agent With Beleifs with vars" do
    defmodule MockAgentWVars do
      use ExAgent.Mod

      initialize do
        +cost(:car, X)
        +cost(Y, Z)
      end

      start()
    end

    test "it captures beleifs in initialize" do
      assert MockAgentWVars.initial ==
        [
          %AddBelief{name: :cost,
          params: [:car,
           %AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1,
            params: [:X]}]},
          %AddBelief{name: :cost,
          params: [%AstFunction{ast: {:__aliases__, [], [:Y]}, number_of_params: 1,
            params: [:Y]},
           %AstFunction{ast: {:__aliases__, [], [:Z]}, number_of_params: 1,
            params: [:Z]}]}]
    end

  end

  describe "Mock Agent With Beleifs and Goals" do
    defmodule MockAgentWBG do
      use ExAgent.Mod

      initialize do
        +cost(:car, 10000)
        +money(111)
        !buy_stuff
      end

      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWBG.initial ==
        [%AddBelief{name: :cost, params: [:car, 10000]},
         %AddBelief{name: :money, params: 'o'},
         %AchieveGoal{name: :buy_stuff, params: []}]
    end

    test "it has a belief base with the initial" do
      ag = MockAgentWBG.create("ag2")
      assert ExAgent.Mod.beliefs(ag) == []
    end
  end

  describe "Mock Agent With replace belief" do
    defmodule MockAgentWBG1 do
      use ExAgent.Mod

      initialize do
        +cost(:car, 10000)
        -+cost(:car, 10000)
      end

      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWBG1.initial ==
        [
          %AddBelief{name: :cost, params: [:car, 10000]},
          %ReplaceBelief{name: :cost, params: [:car, 10000]}
        ]
    end
  end

  describe "Mock Agent with message handler" do
    defmodule MockAgentWMH do
      use ExAgent.Mod
      initialize do end
      message(:inform, s, echo(X)) do end
      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMH.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [],
            head: %MessageHandlerHead{
              sender: :s,
              context: %RuleContext{contexts: [], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with message handler and body" do
    defmodule MockAgentWMHAB do
      use ExAgent.Mod
      initialize do end
      message(:inform, s, echo(X)) do
        &print(X)
        +received(1)
      end
      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMHAB.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [
              %InternalAction{name: :print, params: [%AstFunction{ast: {:__aliases__, [], [:X]}, number_of_params: 1, params: [:X]}]},
              %AddBelief{name: :received, params: [1]}
            ],
            head: %MessageHandlerHead{
              sender: :s,
              context: %RuleContext{contexts: [], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with message handler and body and context" do
    defmodule MockAgentWMHABC do
      use ExAgent.Mod
      initialize do end

      message :inform, sender, echo(X) when should_print(X) && is_ok(1) do
        +received(1)
      end
      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMHABC.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [
              %AddBelief{name: :received, params: [1]}
            ],
            head: %MessageHandlerHead{
              sender: :sender,
              context: %RuleContext{contexts: [
                %ContextBelief{belief: {:should_print, {:X}}, should_pass: true},
                %ContextBelief{belief: {:is_ok, {1}}, should_pass: true}
                ], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with message handler and body and context and function" do
    defmodule MockAgentWMHABCAF do
      use ExAgent.Mod
      initialize do end

      message :inform, s, echo(X) when should_print(X) && is_ok(1) && test 1 == 2 do
        +received(1)
      end
      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMHABCAF.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [
              %AddBelief{name: :received, params: [1]}
            ],
            head: %MessageHandlerHead{
              sender: :s,
              context: %RuleContext{contexts: [
                %ContextBelief{belief: {:should_print, {:X}}, should_pass: true},
                %ContextBelief{belief: {:is_ok, {1}}, should_pass: true}
                ],
                function: %AstFunction{ast: {:==, [], [1, 2]}, number_of_params: 0, params: []}},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with message handler with constants and body and context" do
    defmodule MockAgentWMHABCONST do
      use ExAgent.Mod
      initialize do end

      message :inform, sender, echo("hello") when should_print(X) && is_ok(1) do
        +received(1)
      end
      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMHABCONST.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [
              %AddBelief{name: :received, params: [1]}
            ],
            head: %MessageHandlerHead{
              sender: :sender,
              context: %RuleContext{contexts: [
                %ContextBelief{belief: {:should_print, {:X}}, should_pass: true},
                %ContextBelief{belief: {:is_ok, {1}}, should_pass: true}
                ], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {"hello"}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with multiple message handler" do
    defmodule MockAgentWMMH do
      use ExAgent.Mod
      initialize do end
      message(:inform, sender, echo(X)) do end
      message(:blabla, s, print(Y, Z)) do end

      start()
    end

    test "it captures beleifs in initial" do
      assert MockAgentWMMH.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [],
            head: %MessageHandlerHead{
              sender: :sender,
              context: %RuleContext{contexts: [], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          },
          %MessageHandler{
            atomic: false,
            body: [],
            head: %MessageHandlerHead{
              sender: :s,
              context: %RuleContext{contexts: [], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:print, {:Y, :Z}},
                performative: :blabla
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with send internal action" do
    defmodule MockAgentWMMHWIC do
      use ExAgent.Mod
      initialize do end

      message(:inform, sender, echo(X)) do
        &send("agent1", :inform, echo(X + Y))
      end

      start()
    end

    test "it captures beleifs in initial" do



      assert MockAgentWMMHWIC.message_handlers ==
        [
          %MessageHandler{
            atomic: false,
            body: [%InternalAction{name: :send, params: ["agent1", :inform, %AstFunction{ast: {:echo, [], [{:+, [], [{:__aliases__, [], [:X]}, {:__aliases__, [], [:Y]}]}]}, number_of_params: 2, params: [:X, :Y]}]}],
            head: %MessageHandlerHead{
              sender: :sender,
              context: %RuleContext{contexts: [], function: nil},
              trigger: %MessageHandlerTrigger{
                message: {:echo, {:X}},
                performative: :inform
              }
            }
          }
        ]
    end
  end

  describe "Mock Agent with recovery handler" do
    defmodule MockAgentWRH do
      use ExAgent.Mod
      initialize do end
      recovery (+!count) when counter(0) do end
      start()
    end

    test "it has recovery handlers" do
      first = MockAgentWRH.recovery_handlers |> hd
      assert first.head.trigger.event_type == :added_goal
      assert first.head.context.contexts ==
      [%ContextBelief{belief: {:counter, {0}}, should_pass: true}]

    end
  end

end
