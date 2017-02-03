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


### Plan Rule Example

```
[
  %Rule{
    body: [
      %InternalAction{a: {:print, {"I am really happy man!!!"}}}
    ],
    head: %RuleHead{
      context: 
        %RuleContext{contexts: [], function: nil},
      trigger: 
        %RuleTrigger{event: :added_belief, trigger: {:owns, {:X}}}
    }
  },
  %Rule{
    body: [
      %AddBelief{b: {:owns, {:X}}}, 
      %QueryBelief{b: {:happy, {:N}}},
      %InternalAction{a: {:print, {:X}}}
    ],
    head: %RuleHead{
      context: 
        %RuleContext{
          contexts: [
            cost: {:X, :Y}, 
            money: {:Z}
          ],
          function: 
            %ContextFunction{
              ast: 
                {:>=, [],
                [{:__aliases__, [], [:Z]}, {:__aliases__, [], [:Y]}]},
              number_of_params: 2, 
              params: [:Z, :Y]}
        },
      trigger: 
        %RuleTrigger{
          event: :added_goal, 
          trigger: {:buy, {:X}}
        }
    }
  }
]
```


Agent:
  Initial:
    goal, beliefs
  PlanRules
    trigger, context, body
    body: goal, belief

Each step:
  
