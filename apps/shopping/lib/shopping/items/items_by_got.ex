defmodule Shopping.Items.ItemsByGot do
  alias Shopping.Items.Item

  @enforce_keys [:got, :to_get]
  defstruct [:got, :to_get]

  @type t :: %__MODULE__{got: list(Item.t()), to_get: list(Item.t())}
end
