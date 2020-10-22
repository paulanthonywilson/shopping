defmodule ShoppingWeb.FilteredItemList do
  @moduledoc """
  Applies the filter to the original list of items.

  The fliter algorithm is ...
  """

  alias Shopping.Items.Item

  @enforce_keys [:items, :filtered]
  defstruct [:items, :filtered, filter: ""]
  @type t :: %__MODULE__{items: list(Item.t()), filtered: list(Item.t()), filter: String.t()}

  @spec new(list(Item.t())) :: ShoppingWeb.FilteredItemList.t()
  def new(items) do
    %__MODULE__{
      items: items,
      filtered: items
    }
  end
end
