defmodule RelPlanAgent2 do
  use ExAgent

  message :inform, s, echo("hello") do end
  message :inform, sender, echo(MSG) do end

  message :inform, sender, print_this(A, B) do end

  message :inform, sender1, !buy(Car, Color) when wants(Car) do end
  message :inform, sender2, !buy(Car, Color) when has(Car) && likes(Color) do end
  message :inform, sender3, !buy(Car, Color) when has(Car) && likes(Color, Alot) do end

  # rule (+!sell(Car)) when has(Car) && cost(Car, Price) && test Price > 1000 do end
  # rule (+!sell(Car)) when has(Car) && color(Car, Value) && test Value == :red do end

  # rule (+!buy(Car, Color)) when wants(Car) do end
  # rule (+!buy(Car, Color)) when has(Car) && likes(Color) do end
  # rule (+!buy(Car, Color)) when has(Car) && likes(Color, Alot) do end

  # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
  # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
  # rule (+!buy4(:bmw, Color)) when !has(:bmw) && cost(:bmw, Money) && money(Pocket) && test Pocket > Money do end

  # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket)  && !has(Car) && test Pocket > Money * 2 do end

  # rule (+!buy6(Car)) when wishlist(Wish) && !has(Car) && test String.upcase(Car) == String.upcase(Wish) do end

  start
end

defmodule MessageHandlerSelectionTest do
  use ExUnit.Case


  describe "Relevant Handlers" do
    test "it gets the relevant handlers 1" do
      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :echo, params: ["hello"], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      assert length(relevant) == 2

      assert relevant |> Enum.at(0) |> elem(1)  == [s: self()]
      assert relevant |> Enum.at(1) |> elem(1)  == [MSG: "hello", sender: self()]
    end

    test "it gets the relevant handlers 2" do
      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :echo, params: ["MSG"], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [MSG: "MSG", sender: self()]
    end

    test "it gets the relevant plans 3" do
      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :print_this, params: [1, "2"], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      assert length(relevant) == 1

      assert relevant |> Enum.at(0) |> elem(1)  == [A: 1, B: "2", sender: self()]
    end
  end

  describe "Applicable Handler" do
    test "it gets applicable handlers for simple rule without a function" do
      beliefs = [{:wants, {:bmw}}]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy, params: [:bmw, :red], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red, sender1: self()]]
    end
  end
end
