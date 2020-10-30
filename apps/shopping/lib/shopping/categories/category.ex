defmodule Shopping.Categories.Category do
  @moduledoc false

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  schema "categories" do
    field :category_name, :string
    field :emoji, :string
    field :ordering, :integer

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:emoji, :category_name, :ordering])
    |> validate_required([:emoji, :category_name, :ordering])
  end
end
