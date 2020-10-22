defmodule Shopping.Checklists.Checklist do
  use Ecto.Schema
  import Ecto.Changeset

  alias Shopping.Items.Item

  @type t :: %__MODULE__{}

  schema "checklists" do
    field :name, :string
    has_many :items, Item

    timestamps()
  end

  @doc false
  def changeset(checklist, attrs) do
    checklist
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
