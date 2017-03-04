# Exagent

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add exagent to your list of dependencies in `mix.exs`:

        def deps do
          [{:exagent, "~> 0.0.1"}]
        end

  2. Ensure exagent is started before your application:

        def application do
          [applications: [:exagent]]
        end

## Structure

```
rule (+!buy(X)) when cost(X, Y) && money(Z) && test Z >= Y do
end
```

Rule:
    - Head
    - Body

Rule Head:
    - Rule Event
    - Rule Context

Rule Trigger:
    - Event Type (Added / Removed Goal / Beliefs)
    - Trigger Context. The context that triggered the event

Rule Context:
    - Tests
    - Context Function

RuleBody:
  - Instructions

Initial Beliefs
Message handlers

Instructions:
- Add belief ✔︎
- Remove Belief ✔︎
- Query Belief ︎✔︎
- Achieve Goal ✔︎
- Internal Action ✔︎
- Send message ✔︎
- Halt agent ✔︎

## Runtime


## BNF Grammar

agent           -> (initial_beliefs, initial_goals)* plans
initial_beliefs -> beleifs rules


## Things to do
- Initial beliefs ✔︎
- Dont add a belief if already added ✔︎
- Adding a belief twice wont laucn the plan rule ✔︎
- Sleep in reasoning cycle ✔︎
- Message reading at the end of the cycle exec. If no message wait forever, if any message exec ✔︎
- Message sending between intents ✔︎
- Add a new rule that catch messages ✔︎
- query failing action ✔︎
- Create a intent execution wich contains the binding and instructions ✔︎
- create recovery rule ✔︎
- Goals dont create a new intent, they append a sub intent ✔︎
- Beliefs launch a new intent always ✔︎
- Intent execution interleaving ✔︎
- Atomic rules ✔︎
- Ruseability of rules and beliefs ✔︎
- Gaia ✔︎
- Set a new binding ✔︎
- Add defagent and defresp ✔︎
- Add `foreach`

```

foreach do
  query(participant(X))
  !send_elect(X)
end
[a1, a2, a3]
!send_elect(1)
!send_elect(2)
!send_elect("car")
!send_elect("red")
for_each(participant(Part), !send_elect(Y))
```

## Examples to build
- Counter ✔︎
- Ping Pong ✔︎
- Counter with roles ✔︎
- Ping Pong with roles ✔︎
- Interleaving agent ✔︎
- Atomic Interleaving ✔︎
- Token ring agent that sends to each other
- Bully election algorithm
 

## Questions
- Does replace belief fire both add belief and remove belief events?
- YES!

- Reusability. Put the reuse before or after the agent initial beliefs
- What do we mean by Gaia?

- Modularity
- defrole, roles

- foreach

## BNF

`<Constant>` is an identifier starting with a uppercase letter. Such as; `CounterAgent`
`<Var>` is an identifier starting with a uppercase letter. Such as; `X`, `Y`, `Car`
`<Name>` is snake cased identifier that starts with a lower case letter. Such as `print`
`<ElixirEx>` is any valid elixir expression, function, argument, etc...
`<String>` is any valid elixir string and `<Atom>` is an elixir atom.

```
agent -> "defagent" agent_name "do"
            [roles]
            [initial_beliefs] 
            [initial_actions] 
            (plans)
         "end"

agent_name -> <Constant>

roles -> "roles" "do"
            (role_name "\n")*
          "end"
role_name -> <Constant>

initial_beliefs -> "initial_beliefs" "do"
                      (initial_belief)*
                    "end"

initial_actions -> "initialize" "do"
                      plan_body
                    "end"

plans -> ( plan )*
plan -> rule
        | atomic_rule
        | message
        | atomic_message
        | recovery

rule -> "rule" plan_trigger [ plan_context ] "do"
          plan_body
        "end"
atomic_rule -> "atomic_rule" plan_trigger [ plan_context ] "do"
                  plan_body
               "end"
message -> "message" message_trigger [ plan_context ] "do"
              plan_body
           "end"
atomic_message -> "atomic_message" plan_trigger [ plan_context ] "do"
                    plan_body
                  "end"
recovery -> "recovery" plan_trigger [ plan_context ] "do"
              plan_body
            "end"

plan_trigger -> "(" goal | belief ")"

message_trigger -> performative "," sender_name ","" message_content
performative -> <Atom>
sender_name -> <Name>
message_content -> literal

plan_context -> "when" [ "not" ] literal (  "&&" [ "not" ] literal )* [ "&&" test_func]

test_func -> "test" <ElixirEx>

plan_body -> ( plan_body_item "\n" )*
plan_body_item -> goal 
                  | belief 
                  | query
                  | internal_action

goal -> "!" literal
belief -> ("+" | "-" | "-+") literal
query -> "query" "(" literal ")"
internal_action -> "&" literal

initial_belief -> literal
literal -> <Name> [ "(" list _of_terms ")" ]

list _of_terms -> term ( "," term )*
term -> list
        | arithmatic_expression 
        | <Var> 
        | <String> 
        | <Atom> 
        | <ElixirEx>
list -> "[" [ term ("," term)* ]  "]"

arithmatic_expression -> arithmatic_term [ ( "+" | "-" ) arithmatic_expr ]
arithmatic_term -> arithmatic_simple [ ( "*" | "/" | "div" | "mod" ) arithmatic_term ]
arithmatic_simple -> <NUMBER> 
                    | <Var> 
                    | "-" arithmatic_simple 
                    | "(" arithmatic_expression ")"
```
