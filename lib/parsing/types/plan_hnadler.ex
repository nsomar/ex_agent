defprotocol PlanHandler do
  def trigger_first_parameter(handler)
  def trigger_content(handler)
  def contexts(handler)
end
