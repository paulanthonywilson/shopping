defmodule Shopping.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :got?, :boolean, default: false
    field :important?, :boolean, default: false
    field :name, :string
    field :checklist_id, :id

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :got?, :important?])
    |> validate_required([:name, :got?, :important?])
  end
end
