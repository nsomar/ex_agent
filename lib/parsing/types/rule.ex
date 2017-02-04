defmodule Rule do
  defstruct [:head, :body]
  @type t :: %Rule{head: RuleHead.t, body: RuleBody.t}

  def parse(head, body) do
    %Rule {
      head: RuleHead.parse(head),
      body: RuleBody.parse(body)
    }
  end

end
