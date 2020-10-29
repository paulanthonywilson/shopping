# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shopping.Repo.insert!(%Shopping.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Shopping.{Categories, Checklists, Items}

{:ok, checklist} = Checklists.create_checklist(%{name: "Seedy groceries"})

{:ok, drinks} = Categories.create_category(%{category_name: "Drinks", emoji: "🍷", ordering: 100})

{:ok, ambient} =
  Categories.create_category(%{category_name: "Ambient", emoji: "🍪", ordering: 200})

{:ok, chill} = Categories.create_category(%{category_name: "Chilled", emoji: "⛄️", ordering: 300})
{:ok, veg} = Categories.create_category(%{category_name: "Veg", emoji: "🥦", ordering: 400})

[
  {"Speedboat", nil},
  {"Bananas", veg},
  {"Milk", chill},
  {"Cheese", chill},
  {"Eggs", ambient},
  {"Rice", ambient},
  {"Risotto rice", ambient},
  {"Wine", drinks},
  {"Juice", chill},
  {"Cooking oil", ambient}
]
|> Enum.with_index()
|> Enum.map(fn {{item, cat}, i} ->
  attrs = %{
    name: item,
    important?: i < 3,
    got?: i > 7
  }

  {:ok, item} = Items.create_item(checklist, attrs)

  case cat do
    nil -> :ok
    cat -> Items.set_category(item, cat)
  end
end)
