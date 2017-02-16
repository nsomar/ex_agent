defmodule IntentionTests do
  use ExUnit.Case

  test "It knows when an intent has no instructions" do
    intent = Intention.create([I], E, B, P)
    assert Intention.has_instructions?(intent) == true
  end

  test "It knows when an intent has no instructions 1" do
    intent = Intention.create([], E, B, P)
    assert Intention.has_instructions?(intent) == false
  end

  test "It gets the next instruction" do
    intent = Intention.create([I1, I2], E, B1, P)

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I1
    assert bindings == B1
    assert intent == %Intention{executions: [%IntentionExecution{bindings: B1, event: E, instructions: [I2], plan: P}]}

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I2
    assert bindings == B1
    assert intent == :no_intent
  end

  test "It push a new execution on the intent" do
    intent = Intention.create([I11], E1, B1, P1)
    intent = Intention.push(intent, [I21, I22], E2, B2, P2)

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I21
    assert bindings == B2

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I22
    assert bindings == B2

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I11
    assert bindings == B1
    assert intent == :no_intent
  end

   test "It updates the binding of the top execution" do
    intent = Intention.create([I11], E1, B1, P1)
    intent = Intention.push(intent, [I21, I22], E2, B2, P2)

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I21
    assert bindings == B2

    intent = Intention.update_bindings(intent, B22)

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I22
    assert bindings == B22

    {instruction, bindings, intent} = Intention.next_instruction(intent)
    assert instruction == I11
    assert bindings == B1
    assert intent == :no_intent
  end

end
