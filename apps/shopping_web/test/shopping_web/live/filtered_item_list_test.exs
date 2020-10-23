defmodule ShoppingWeb.FilteredItemListTest do
  use ExUnit.Case

  alias Shopping.Items.Item
  alias ShoppingWeb.FilteredItemList

  describe "empty list" do
    test "with empty filter" do
      assert FilteredItemList.filter([], "") == []
    end

    test "with non-empty filter" do
      assert FilteredItemList.filter([], "") == []
    end
  end

  describe "non empty list" do
    test "with empty filter" do
      assert FilteredItemList.filter([%Item{lcase_name: "alfred"}], "") == [
               %Item{lcase_name: "alfred"}
             ]
    end

    test "with non-empty filter returns all that partially match" do
      items = for name <- ["alfred", "mavis", "alfonso", "ethalfred"], do: %Item{lcase_name: name}

      assert FilteredItemList.filter(items, "Alf") |> Enum.map(& &1.lcase_name) == [
               "alfred",
               "alfonso",
               "ethalfred"
             ]
    end
  end
end
