defmodule Shopping.ItemsTest do
  use Shopping.DataCase

  alias Shopping.{Items, Checklists}
  alias Items.Item

  @valid_attrs %{got?: true, important?: true, name: "Some name"}
  @update_attrs %{got?: false, important?: false, name: "Some updated name"}
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

    test "list_items/0 returns all items", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert Items.list_items() == [item]
    end

    test "get_item!/1 returns the item with given id", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert Items.get_item!(item.id) == item
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

    test "update_item/2 with valid data updates the item", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert {:ok, %Item{} = item} = Items.update_item(item, @update_attrs)
      assert item.got? == false
      assert item.important? == false
      assert item.name == "Some updated name"
      assert item.lcase_name == "some updated name"
    end

    test "update_item/2 with invalid data returns error changeset", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert {:error, %Ecto.Changeset{}} = Items.update_item(item, @invalid_attrs)
      assert item == Items.get_item!(item.id)
    end

    test "delete_item/1 deletes the item", %{checklist: checklist} do
      item = item_fixture(checklist)
      assert {:ok, %Item{}} = Items.delete_item(item)
      assert_raise Ecto.NoResultsError, fn -> Items.get_item!(item.id) end
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

    test "items still to get ordered by importance, then name", %{checklist: checklist} do
      items = Items.list_by_got(checklist)

      assert [true, true, false, false, false] ==
               Enum.map(items.to_get, & &1.important?)

      assert ["Item 4", "Item 5", "Item 1", "Item 2", "Item 3"] ==
               Enum.map(items.to_get, & &1.name)
    end
  end

  describe "change importance" do
    test "important to unimportant", %{checklist: checklist} do
      Items.subscribe(checklist)
      item = item_fixture(checklist, %{important?: true})
      assert {:ok, changed} = Items.change_importance_to(item, false)
      assert changed == Items.get_item!(item.id)
      refute changed.important?
      assert_receive {"item-change-importance", ^changed}
    end

    test "unimportant to important", %{checklist: checklist} do
      Items.subscribe(checklist)
      item = item_fixture(checklist, %{important?: false})
      assert {:ok, changed} = Items.change_importance_to(item.id, true)
      assert changed == Items.get_item!(item.id)
      assert changed.important?
      assert_receive {"item-change-importance", ^changed}
    end
  end

  test "no cross-checklist events when subscribed to a checklist", %{checklist: checklist} do
    {:ok, other_checklist} = Checklists.create_checklist(%{name: "other"})
    item = item_fixture(other_checklist, %{important?: false})

    Items.subscribe(checklist)
    {:ok, changed} = Items.change_importance_to(item.id, true)

    refute_receive {"item-change-importance", ^changed}
  end

  describe "change got?" do
    test "not got to got", %{checklist: checklist} do
      Items.subscribe(checklist)
      item = item_fixture(checklist, %{got?: false, important?: true})
      assert {:ok, changed} = Items.change_got_to(item, true)
      assert changed == Items.get_item!(item.id)

      assert changed.got?
      refute changed.important?

      assert_receive {"item-change-got", ^changed}
    end

    test "got to not got", %{checklist: checklist} do
      Items.subscribe(checklist)
      item = item_fixture(checklist, %{got?: true, important?: true})

      assert {:ok, changed} = Items.change_got_to(item.id, false)
      assert changed == Items.get_item!(item.id)

      refute changed.got?
      refute changed.important?

      assert_receive {"item-change-got", ^changed}
    end
  end

  describe "update in list of items" do
    test "item is in list" do
      items = for i <- 1..10, do: %Item{important?: false, id: i, name: "Item #{i}"}

      change = %Item{
        id: 5,
        important?: true,
        name: "Item 5"
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
end
