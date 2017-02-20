defmodule ExAgent.Core do
  require Logger

  ############################################################################
  # Using
  ############################################################################

  defmacro __using__(_) do
    quote do

      import unquote(ExAgent.Core)
      require Logger

      @initial []
      @responsibilities []
      @initial_beliefs []
      @started false

      @after_compile __MODULE__

      Module.register_attribute __MODULE__, :rule_handlers,
      accumulate: true, persist: false

      Module.register_attribute __MODULE__, :message_handlers,
      accumulate: true, persist: false

      Module.register_attribute __MODULE__, :recovery_handlers,
      accumulate: true, persist: false

      defmacro __after_compile__(_, _) do
        quote do
          unless @started do
            CompilerHelpers.print_aget_not_started_message(__MODULE__)
          end
        end
      end
    end
  end

  ############################################################################
  # Macros
  ############################################################################

  defmacro initialize(funcs) do
    quote bind_quoted: [funcs: funcs |> Macro.escape] do
      @initial funcs |> RuleBody.parse
    end
  end

  defmacro initial_beliefs(funcs) do
    quote bind_quoted: [funcs: funcs |> Macro.escape] do
      @initial_beliefs funcs |> InitialBeliefs.parse
    end
  end

  # on(+cost(X, Y), money(Z) && nice(X) && not want_to_buy(X) &&
  #        fn x, y, z -> x == y end) do
  defmacro on(_, _, _) do
    quote do
      1
    end
  end

  # rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro rule(head, body) do
    r = Rule.parse(head, body, false) |> Macro.escape

    quote bind_quoted: [r: r] do
      @rule_handlers r
    end
  end

  # atomic_rule (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro atomic_rule(head, body) do
    r = Rule.parse(head, body, true) |> Macro.escape

    quote bind_quoted: [r: r] do
      @rule_handlers r
    end
  end

  # recover (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro recovery(head, body) do
    r = Rule.parse(head, body) |> Macro.escape

    quote bind_quoted: [r: r] do
      @recovery_handlers r
    end
  end

  # message (+!buy(X)) when money(Z) && cost(X, C) && test Z > X && test Z == X do
  defmacro message(performative, sender, head, body) do
    r = MessageHandler.parse(performative, sender, head, body) |> Macro.escape

    quote bind_quoted: [r: r] do
      @message_handlers r
    end
  end

  defmacro atomic_message(performative, sender, head, body) do
    r = MessageHandler.parse(performative, sender, head, body, true) |> Macro.escape

    quote bind_quoted: [r: r] do
      @message_handlers r
    end
  end

  defmacro responsibilities(r) do
    quote bind_quoted: [r: r |> Macro.escape] do
      @responsibilities r |> Responsibility.parse
    end
  end

  defmacro start do
    quote do
      @started true
      def initial, do: @initial
      def initial_beliefs, do: @initial_beliefs
      def plan_rules, do: @rule_handlers |> Enum.reverse
      def recovery_handlers, do: @recovery_handlers |> Enum.reverse
      def message_handlers, do: @message_handlers |> Enum.reverse
      def responsibilities, do: @responsibilities
    end
  end
end
