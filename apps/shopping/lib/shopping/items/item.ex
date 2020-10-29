defmodule Shopping.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  alias Shopping.Categories.Category

  @type t :: %__MODULE__{}

  schema "items" do
    field :got?, :boolean, default: false
    field :important?, :boolean, default: false
    field :name, :string
    field :lcase_name, :string
    field :checklist_id, :id
    belongs_to :category, Category

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :lcase_name, :got?, :important?, :category_id])
    |> validate_required([:name, :lcase_name, :got?, :important?])
    |> validate_lcase_name()
    |> unique_constraint(:name,
      name: :items_checklist_id_lcase_name_index,
      message: "already in the list"
    )
  end

  defp validate_lcase_name(changeset) do
    {_, name} = fetch_field(changeset, :name)
    {_, lcase_name} = fetch_field(changeset, :lcase_name)

    if name && String.downcase(name) == lcase_name do
      changeset
    else
      add_error(
        changeset,
        :lcase_name,
        "lcase_name (#{lcase_name}) should be the lower case of name (#{name})"
      )
    end
  end
end
