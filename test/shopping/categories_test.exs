defmodule Shopping.CategoriesTest do
  use Shopping.DataCase

  alias Shopping.Categories

  @valid_attrs %{category_name: "Frozen", emoji: "⛄️", ordering: 100}
  @invalid_attrs %{category_name: nil}

  def category_fixture(ordering, attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Map.put(:ordering, ordering)
      |> Enum.into(@valid_attrs)
      |> Categories.create_category()

    category
  end

  describe "creating a category" do
    test "returns category when successful" do
      assert {:ok, category} = Categories.create_category(@valid_attrs)
      assert @valid_attrs = category
      assert [@valid_attrs, _] = Categories.list_all_categories()
    end

    test "return error when unsuccessful" do
      assert {:error, %Ecto.Changeset{}} = Categories.create_category(@invalid_attrs)
    end
  end

  describe "listing " do
    test "returns in order of ordering, descending" do
      {:ok, _} = Categories.create_category(%{category_name: "Frozen", emoji: "⛄️", ordering: 100})

      {:ok, _} = Categories.create_category(%{category_name: "Chilled", emoji: "🆒", ordering: 90})

      {:ok, _} =
        Categories.create_category(%{category_name: "Alcohol", emoji: "🍷", ordering: 110})

      assert ["🍷", "⛄️", "🆒", "🤷🏻‍♀️"] == Categories.list_all_categories() |> Enum.map(& &1.emoji)
    end
  end
end
