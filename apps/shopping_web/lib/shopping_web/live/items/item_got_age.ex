defmodule ShoppingWeb.ItemGotAge do
  @moduledoc """
  For displaying in human readable form how long it has been since the item
  was last got
  """

  @_1_hour 60 * 60
  @_2_hours @_1_hour * 2
  @_24_hours @_1_hour * 24
  @_2_days @_24_hours * 2

  def got_age(now \\ nil, item)
  def got_age(_, %{last_got: nil}), do: ""

  def got_age(now, %{last_got: last_got}) do
    now = now || DateTime.utc_now()
    age(DateTime.diff(now, last_got))
  end

  defp age(age) when age < @_1_hour, do: "last hour"
  defp age(age) when age < @_2_hours, do: "1 hour"
  defp age(age) when age < @_24_hours, do: "#{div(age, @_1_hour)} hours"
  defp age(age) when age < @_2_days, do: "1 day"
  defp age(age), do: "#{div(age, @_24_hours)} days"
end
