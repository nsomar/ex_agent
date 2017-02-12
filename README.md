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

Instructions:
- Add belief ✔︎
- Remove Belief ✔︎
- Query Belief ︎✔︎
- Achieve Goal ✔︎
- Internal Action ✔︎
- Send message ✔︎

## Runtime


## BNF Grammar

agent           -> (initial_beliefs, initial_goals)* plans
initial_beliefs -> beleifs rules


## Things to do
- Initial beliefs ✔︎
- Dont add a belief if already added ✔︎
- Adding a belief twice wont laucn the plan rule ✔︎
- Sleep in reasoning cycle ✔︎
- Goals dont create a new intent, they append a sub intent
- Create a intent execution wich contains the binding and instructions
- Beliefs launch a new intent always
- Intent execution interleaving
- Message reading at the end of the cycle exec. If no message wait forever, if any message exec
- Message sending between intents
- Add a new rule that catch messages
- create recovery rule
- Atomic rules
- query failing action
- Ruseability of rules and beliefs
- Gaia

## Examples to build
- Counter
- Ping Pong
- One shot auction
 

## Questions
- Does replace belief fire both add belief and remove belief events?
