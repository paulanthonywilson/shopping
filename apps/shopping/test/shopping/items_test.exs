defmodule Shopping.ItemsTest do
  use Shopping.DataCase

  alias Shopping.{Items, Checklists}
  alias Items.Item

  describe "items" do
    alias Shopping.Items.Item

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
end
