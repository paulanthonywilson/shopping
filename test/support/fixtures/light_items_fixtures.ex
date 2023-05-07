defmodule LightItemsFixtures do
  alias Shopping.{Items.Item, Categories.Category}

  def some_test_items(count, got?) do
    for i <- 1..count do
      test_item(i, "Item #{i}", got?)
    end
  end

  def test_item(id, name, got?, opts \\ []) do
    %Item{
      id: id,
      name: name,
      got?: got?,
      checklist_id: 1,
      last_got: Keyword.get(opts, :last_got),
      important?: Keyword.get(opts, :important?),
      lcase_name: String.downcase(name),
      category_id: 1,
      category: test_category(1, Keyword.get(opts, :emoji, "😍"), "stuff")
    }
  end

  def test_category(id, emoji, name) do
    %Category{
      id: id,
      emoji: emoji,
      category_name: name
    }
  end
end
