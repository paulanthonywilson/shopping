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

alias Shopping.{Checklists, Items}

{:ok, checklist} = Checklists.create_checklist(%{name: "Seedy groceries"})

["Milk", "Cheese", "Eggs", "Rice", "Risotto rice", "Wine", "Juice", "Cooking oil"]
|> Enum.with_index()
|> Enum.map(fn {item, i} ->
  important? = i < 3
  got? = i > 7

  Items.create_item(checklist, %{name: item, important?: important?, got?: got?})
end)
