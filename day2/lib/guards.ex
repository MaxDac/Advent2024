defmodule Guards do
  @moduledoc """
  Set of guards for check readability.
  """

  defguard is_safe_interval(one, two) when one != two and abs(one - two) >= 1 and abs(one - two) <= 3

  defguard is_up_interval(one, two) when two - one > 0

  defguard is_down_interval(one, two) when one - two > 0
end
