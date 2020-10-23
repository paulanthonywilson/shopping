defmodule ShoppingWeb.FilteredItemList do
  @moduledoc """
  Applies the filter to the original list of items.

  The fliter algorithm is simply whether the (lower case) filter is present
  in the item's `lcase_name`
  """

  alias Shopping.Items.Item

  @doc """
  Filter the list
  """
  @spec filter(list(Item.t()), Strint.t()) :: list(Item.t())
  def filter(item_list, filter) do
    filter = String.downcase(filter)
    Enum.filter(item_list, fn %Item{lcase_name: lname} -> lname =~ filter end)
  end
end
