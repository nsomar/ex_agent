defmodule RelPlanAgent2 do
  use ExAgent.Mod

  message :inform, s, echo("hello") do end
  message :inform, sender, echo(MSG) do end

  message :inform, sender, print_this(A, B) do end

  message :inform, sender1, buy(Car, Color) when wants(Car) do end
  message :inform, sender2, buy(Car, Color) when has(Car) && likes(Color) do end
  message :inform, sender3, buy(Car, Color) when has(Car) && likes(Color, Alot) do end

  message :inform, s, sell(Car) when has(Car) && cost(Car, Price) && test Price > 1000 do end
  message :inform, s, sell(Car) when has(Car) && color(Car, Value) && test Value == :red do end

  message :request, s, buy2(Car, Color) when not has(Car) && cost(Car, Money) && money(Money) do end

  message :request, s, buy3(Car, Color) when not has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end

  message :request, s, buy4(:bmw, Color) when not has(:bmw) && cost(:bmw, Money) && money(Pocket) && test Pocket > Money do end
  message :request, s, buy5(Car, Color) when cost(Car, Money) && money(Pocket)  && not has(Car) && test Pocket > Money * 2 do end
  message :request, s, buy6(Car) when wishlist(Wish) && not has(Car) && test String.upcase(Car) == String.upcase(Wish) do end

  start()
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

    test "it gets applicable handlers for simple rule without a function when multiple beliefs match" do
      beliefs = [{:wants, {:bmw}}, {:wants, {:opel}}]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy, params: [:bmw, :red], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)

      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red, sender1: self()]]
    end

    test "it gets applicable handlers for simple rule without a function when multiple beliefs match 2" do
      beliefs = [
        {:wants, {:bmw}},
        {:wants, {:opel}},
        {:has, {:bmw}},
        {:likes, {:red, true}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy, params: [:bmw, :red], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 2
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red, sender1: self()]]
      assert applicable |> Enum.at(1) |> elem(1) == [[Car: :bmw, Color: :red, sender3: self(), Alot: true]]
    end

    test "it gets applicable plans for simple rule without a function 2" do
      beliefs = [{:has, {:bmw}}, {:likes, {:red}}]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy, params: [:bmw, :red], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> Enum.at(0) |> elem(1) == [[Car: :bmw, Color: :red, sender2: self()]]
    end

    test "it does not get plans that dont match the beliefs" do
      beliefs = [{:wants, {:opel}}]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy, params: [:bmw, :red], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get applicable plans for rule with a function when the function does not pass" do
      beliefs = [
        {:has, {:bmw}},
        {:cost, {:bmw, 100}},
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :sell, params: [:bmw], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get applicable plans for rule with a function when the function does not pass 2" do
      beliefs = [
        {:has, {:bmw}},
        {:color, {:bmw, :green}},
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :sell, params: [:bmw], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it gets applicable plans for rule with a function when the function passes" do
      beliefs = [
        {:has, {:bmw}},
        {:cost, {:bmw, 10000}},
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :sell, params: [:bmw], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, s: self(), Price: 10000]]
    end

    test "it gets applicable plans for rule with a function when the function passes 2" do
      beliefs = [
        {:has, {:bmw}},
        {:color, {:bmw, :red}},
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :sell, params: [:bmw], performative: :inform, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, s: self(), Value: :red]]
    end
  end

  describe "Applicable Plans With False tests" do

     test "it gets the car if has enough money and car is not owned" do
      # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
      beliefs = [
        {:money, {1000}},
        {:cost, {:bmw, 1000}},
        {:has, {:bmw}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy2, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

    test "it does not get the car if has enough money and car is owned" do
      # rule (+!buy2(Car, Color)) when !has(Car) && cost(Car, Money) && money(Money) do end
      beliefs = [
        {:money, {1000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy2, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, s: self(), Money: 1000]]
    end

  end

  describe "Applicable Plans With False tests and function" do

    test "it gets the car if has enough money" do
      # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {10000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy3, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, s: self(), Money: 1000, Pocket: 10000]]
    end

    test "it does not get car if does not have enough money" do
      # rule (+!buy3(Car, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {100}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy3, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

  end

  describe "Applicable Plans With False tests and function and constants" do

    test "it gets the car if has enough money" do
      # rule (+!buy4(:bmw, Color)) when !has(Car) && cost(Car, Money) && money(Pocket) && test Pocket > Money do end
      beliefs = [
        {:money, {10000}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy4, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Color: :red, s: self(), Money: 1000, Pocket: 10000]]
    end

  end

  describe "Applicable Plans With False tests and arithmatic" do

    test "it gets the car if has more than double the price" do
      # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket) && test Pocket > Money && !has(Car) do end
      beliefs = [
        {:money, {2001}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy5, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: :bmw, Color: :red, s: self(), Money: 1000, Pocket: 2001]]
    end

    test "it does not get the car if has more less than double the price" do
      # rule (+!buy5(Car, Color)) when cost(Car, Money) && money(Pocket) && test Pocket > Money && !has(Car) do end
      beliefs = [
        {:money, {1999}},
        {:cost, {:bmw, 1000}},
        {:has, {:opel}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy5, params: [:bmw, :red], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 0
    end

  end

  describe "Applicable Plans With False tests and arithmatic" do

    test "it gets the car if its in the wish list" do
      # rule (+!buy6(Car)) when wishlist(Wish) && !has(Car) && test String.capitalize(Car) == String.capitalize(Wish) * 2 do end
      beliefs = [
        {:wishlist, {"BMW"}},
        {:has, {"opel"}}
      ]

      all_handlers = RelPlanAgent2.message_handlers
      event = %Event{content: %Message{name: :buy6, params: ["bmw"], performative: :request, from: self()}, event_type: :received_message, intents: nil}

      relevant = MessageHandlerSelection.relavent_handlers(all_handlers, event)
      applicable = MessageHandlerSelection.applicable_handlers(relevant, beliefs)
      assert length(applicable) == 1
      assert applicable |> hd |> elem(1) == [[Car: "bmw", s: self(), Wish: "BMW"]]
    end

  end

end
