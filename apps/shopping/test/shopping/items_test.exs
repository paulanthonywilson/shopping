defmodule Shopping.ItemsTest do
  use Shopping.DataCase

  alias Shopping.{Items, Categories, Checklists}
  alias Shopping.Items.Item
  alias Shopping.Categories.Category

  @valid_attrs %{got?: true, important?: true, name: "Some name"}
  @invalid_attrs %{got?: nil, important?: nil, name: nil}

  setup do
    {:ok, checklist} = Checklists.create_checklist(%{name: "some checklist"})
    %{checklist: checklist}
  end

  def item_fixture(checklist, attrs \\ %{}) do
    attrs = Enum.into(attrs, @valid_attrs)

    case Items.create_item(checklist, attrs) do
      {:ok, item} -> item
    end
  end

  describe "items" do
    test "item changeset requires lcase_name to be the lower case of name" do
      valid = Map.merge(@valid_attrs, %{name: "UPPER", lcase_name: "upper"})
      invalid = Map.merge(@valid_attrs, %{name: "UPPER", lcase_name: "Upper"})
      assert %{valid?: true} = Item.changeset(%Item{}, valid)
      assert %{valid?: false} = Item.changeset(%Item{}, invalid)
    end

    test "list_items/1 returns all items", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert Items.list_items() == [reload(item)]
    end

    test "list_items/1 preloads the item category", %{checklist: checklist} do
      item_fixture(checklist)

      [item] = Items.list_items(checklist)

      assert %Category{id: 0} = item.category
    end

    test "get_item!/1 returns the item with given id and preloaded category", %{
      checklist: checklist
    } do
      item = item_fixture(checklist)
      assert Items.get_item!(item.id) == item
    end

    test "get_item!/1 preloads category", %{checklist: checklist} do
      %{id: id} = item_fixture(checklist)
      item = Items.get_item!(id)
      assert %Category{id: 0} = item.category
    end

    test "create_item/1 with valid data creates a item", %{checklist: checklist} do
      assert {:ok, %Item{} = item} = Items.create_item(checklist, @valid_attrs)
      assert item.got? == true
      assert item.important? == true
      assert item.name == "Some name"
      assert item.lcase_name == "some name"
    end

    test "create item with string keyed attributes", %{checklist: checklist} do
      attrs =
        @valid_attrs
        |> Enum.map(fn {k, v} -> {to_string(k), v} end)
        |> Enum.into(%{})

      assert {:ok, item} = Items.create_item(checklist, attrs)
      assert item.name == "Some name"
      assert item.lcase_name == "some name"
    end

    test "create_item/1 with invalid data returns error changeset", %{checklist: checklist} do
      assert {:error, %Ecto.Changeset{}} = Items.create_item(checklist, @invalid_attrs)
    end

    test "unique constraint on lower case name", %{checklist: checklist} do
      item_fixture(checklist, %{name: "Bread"})
      assert {:error, changeset} = Items.create_item(checklist, %{name: "bread"})
      assert [{:name, {"already in the list", _}}] = changeset.errors
    end

    test "create item broadcasts creation to subscribers", %{checklist: checklist} do
      :ok = Items.subscribe(checklist)
      {:ok, item} = Items.create_item(checklist, @valid_attrs)

      assert_receive {"item-created", ^item}
    end

    test "create item preloads the default category on return and broadcast", %{
      checklist: checklist
    } do
      :ok = Items.subscribe(checklist)
      {:ok, item} = Items.create_item(checklist, @valid_attrs)

      assert %Category{id: 0} = item.category

      assert_receive {"item-created", item}

      assert %Category{id: 0} = item.category
    end

    test "delete_item/1 deletes the item", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert {:ok, %Item{}} = Items.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
    end

    test "delete item with id", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert {:ok, %Item{}} = Items.delete_item(item.id)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
    end

    test "deleting an item broadcasts an event", %{checklist: checklist} do
      item = item_fixture(checklist)

      :ok = Items.subscribe(checklist)

      {:ok, item} = Items.delete_item(item)

      assert_receive {"item-deleted", ^item}
    end

    test "change_item/1 returns a item changeset", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert %Ecto.Changeset{} = Items.change_item(item)
    end
  end

  describe "listing items" do
    setup %{checklist: checklist} do
      {:ok, other_checklist} = Checklists.create_checklist(%{name: "some checklist"})

      for i <- 1..9 do
        important? = i < 7
        got? = i < 5

        Items.create_item(checklist, %{name: "Item #{10 - i}", important?: important?, got?: got?})

        Items.create_item(other_checklist, %{
          name: "Other item #{i}",
          important?: important?,
          got?: got?
        })
      end

      %{other_checklist: other_checklist}
    end

    test "listing checklist items", %{checklist: checklist} do
      items = Items.list_items(checklist)
      assert length(items) == 9

      assert ["Item 1", "Item 2" | _] = Enum.map(items, & &1.name)
    end

    test "listing by got", %{checklist: checklist} do
      items = Items.list_by_got(checklist)

      assert length(items.got) == 4
      assert length(items.to_get) == 5

      assert [true] = items.got |> Enum.map(& &1.got?) |> Enum.uniq()
      assert [false] = items.to_get |> Enum.map(& &1.got?) |> Enum.uniq()
    end

    test "items still to get ordered by category, importance, then name", %{checklist: checklist} do
      items = Items.list_by_got(checklist)

      assert [true, true, false, false, false] ==
               Enum.map(items.to_get, & &1.important?)

      assert ["Item 4", "Item 5", "Item 1", "Item 2", "Item 3"] ==
               Enum.map(items.to_get, & &1.name)
    end
  end

  describe "change importance" do
    test "important to unimportant", %{checklist: checklist} do
      item = item_fixture(checklist, %{important?: true})
      Items.subscribe(checklist)
      assert {:ok, changed} = Items.change_importance_to(item, false)
      assert changed == Items.get_item!(item.id)
      refute changed.important?
      assert_receive {"item-changed-importance", ^changed}
    end

    test "unimportant to important", %{checklist: checklist} do
      item = item_fixture(checklist, %{important?: false})
      Items.subscribe(checklist)
      assert {:ok, changed} = Items.change_importance_to(item.id, true)
      assert changed == Items.get_item!(item.id)
      assert changed.important?
      assert_receive {"item-changed-importance", ^changed}
    end
  end

  test "no cross-checklist events when subscribed to a checklist", %{checklist: checklist} do
    {:ok, other_checklist} = Checklists.create_checklist(%{name: "other"})
    item = item_fixture(other_checklist, %{important?: false})

    Items.subscribe(checklist)
    {:ok, changed} = Items.change_importance_to(item.id, true)

    refute_receive {"item-changed-importance", ^changed}
  end

  describe "change got?" do
    test "not got to got", %{checklist: checklist} do
      item = item_fixture(checklist, %{got?: false, important?: true})

      Items.subscribe(checklist)
      assert {:ok, changed} = Items.change_got_to(item, true)
      assert changed == Items.get_item!(item.id)

      assert changed.got?
      refute changed.important?

      assert_receive {"item-changed-got", ^changed}
    end

    test "got to not got", %{checklist: checklist} do
      item = item_fixture(checklist, %{got?: true, important?: true})

      Items.subscribe(checklist)
      assert {:ok, changed} = Items.change_got_to(item.id, false)
      assert changed == Items.get_item!(item.id)

      refute changed.got?
      refute changed.important?

      assert_receive {"item-changed-got", ^changed}
    end
  end

  describe "update in list of items" do
    test "item is in list" do
      category = %Category{ordering: 100}

      items =
        for i <- 1..10, do: %Item{important?: false, id: i, name: "Item #{i}", category: category}

      change = %Item{
        id: 5,
        important?: true,
        name: "Item 5",
        category: category
      }

      new_items = Items.update_in_list_of_items(items, change)

      assert length(new_items) == 10
      assert [^change | _] = new_items
    end

    test "item is not in list" do
      items = for i <- 1..10, do: %Item{important?: false, id: i, name: "Item #{i}"}

      new_items = Items.update_in_list_of_items(items, %Item{id: 11, important?: false})

      assert new_items == items
    end
  end

  describe "remove from list of items" do
    test "item is in list" do
      items = for i <- 1..10, do: %Item{important?: false, id: i, name: "Item #{i}"}

      [_, _, _, remove | _] = items

      new_items = Items.remove_item_from_list(items, remove)

      assert remove.id not in Enum.map(new_items, & &1.id)
      assert length(new_items) == 9
    end

    test "item is not in list" do
      items = for i <- 1..10, do: %Item{important?: false, id: i, name: "Item #{i}"}

      new_items = Items.update_in_list_of_items(items, %Item{id: 11, important?: false})

      assert new_items == items
    end
  end

  describe "add to list of items" do
    setup do
      category = %Category{ordering: 100}

      items =
        for i <- 1..5, do: %Item{important?: false, id: i, name: "Item #{i}", category: category}

      {:ok, items: items, category: category}
    end

    test "item added to list in display order", %{items: items, category: category} do
      new_items =
        Items.add_to_list(items, %Item{
          important?: false,
          id: 30,
          name: "Item 30",
          category: category
        })

      assert [1, 2, 3, 30, 4, 5] == Enum.map(new_items, & &1.id)
    end

    test "item added to list that already exists (by id) is ignored", %{
      items: items,
      category: category
    } do
      new_items =
        Items.add_to_list(items, %Item{
          important?: false,
          id: 3,
          name: "Item 30",
          category: category
        })

      assert [1, 2, 3, 4, 5] == Enum.map(new_items, & &1.id)
    end
  end

  describe "sorting for display" do
    test "sorts by category ordering (desc), then by important first, then by name" do
      {:ok, high} =
        Categories.create_category(%{ordering: 110, category_name: "Vegetables", emoji: "🥕"})

      {:ok, medium} =
        Categories.create_category(%{ordering: 100, category_name: "Chilled", emoji: "🥶"})

      {:ok, low} =
        Categories.create_category(%{ordering: 90, category_name: "Drinks", emoji: "🍹"})

      items =
        for i <- 8..0 do
          category =
            case Integer.mod(i, 3) do
              0 -> high
              1 -> medium
              2 -> low
            end

          %Item{category: category, important?: i > 5, name: to_string(i)}
        end

      assert ~w(6 0 3 7 1 4 8 2 5) ==
               items
               |> Items.sort_for_display()
               |> Enum.map(& &1.name)
    end
  end

  describe "set item category" do
    setup %{checklist: checklist} do
      {:ok, category} =
        Categories.create_category(%{ordering: 90, category_name: "Drinks", emoji: "🍹"})

      item = item_fixture(checklist, %{name: "Piña colada"})
      :ok = Items.subscribe(checklist)
      {:ok, category: category, item: item}
    end

    test "sets item", %{category: category, item: item} do
      assert {:ok, _item} = Items.set_category(item, category)

      assert %{category_name: "Drinks"} = Items.get_item!(item.id).category
    end

    test "broadcasts category change", %{item: item, category: category} do
      assert {:ok, _item} = Items.set_category(item, category)

      assert_receive {"item-changed-category",
                      %Item{name: "Piña colada", category: %Category{emoji: "🍹"}}}
    end

    test "with category id", %{item: item, category: category} do
      assert {:ok, _item} = Items.set_category(item, category.id)
      assert %{category_name: "Drinks"} = Items.get_item!(item.id).category

      assert_receive {"item-changed-category",
                      %Item{name: "Piña colada", category: %Category{emoji: "🍹"}}}
    end
  end
end
