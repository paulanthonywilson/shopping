defmodule ShoppingWeb.Items.EditItemComponentTest do
  use ShoppingWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import LightItemsFixtures

  alias Phoenix.LiveView.Socket

  alias Shopping.{Categories, Checklists, Items, Repo}
  alias ShoppingWeb.Items.EditItemComponent

  setup do
    {:ok,
     item: test_item(5, "thing", false, emoji: "😍"),
     categories: [
       test_category(0, "🤷", "dunnolol"),
       test_category(1, "😍", "stuff"),
       test_category(2, "🤓", "things"),
       test_category(3, "😎", "cool stuff")
     ]}
  end

  describe "do on rendering" do
    setup %{item: item, categories: categories} do
      {:ok, html: render(item, categories)}
    end

    test "displays category name", %{html: html} do
      assert html |> Floki.find("header") |> Floki.text() =~ "thing"
    end

    test "provides a select box with all the categories", %{html: html} do
      assert [
               {"option", [{"value", "0"}], ["🤷 dunnolol"]},
               {"option", [_, _] = selected_attrs, ["😍 stuff"]},
               {"option", [{"value", "2"}], ["🤓 things"]},
               {"option", [{"value", "3"}], ["😎 cool stuff"]}
             ] =
               Floki.find(
                 html,
                 "form[phx-change='change-category'][phx-target='1'] select[name='category'] option"
               )

      assert List.keyfind(selected_attrs, "selected", 0)
      assert List.keyfind(selected_attrs, "value", 0) == {"value", "1"}
    end
  end

  describe "actions for " do
    setup do
      {:ok, checklist} = Checklists.create_checklist(%{name: "shopping"})
      {:ok, item} = Items.create_item(checklist, %{name: "fish"})

      socket =
        %Socket{}
        |> Map.update!(:assigns, fn assigns ->
          assigns
          |> Map.put(:item, item)
          |> Map.put(:patch, "/somewhere")
        end)

      {:ok, item: item, socket: socket}
    end

    test "updating the category", %{item: item, socket: socket} do
      {:ok, %{id: new_cat_id}} =
        Categories.create_category(%{category_name: "wet", emoji: "🌊", ordering: 1})

      assert {:noreply, %Socket{redirected: {:live, :patch, %{kind: :push, to: "/somewhere"}}}} =
               EditItemComponent.handle_event(
                 "change-category",
                 %{"category" => to_string(new_cat_id)},
                 socket
               )

      assert %{category_id: ^new_cat_id} = Items.get_item!(item.id)
    end

    test "deleting the item", %{item: item, socket: socket} do
      assert {:noreply, %Socket{redirected: {:live, :patch, %{kind: :push, to: "/somewhere"}}}} =
               EditItemComponent.handle_event("delete", %{}, socket)

      assert Items.Item
             |> Repo.get(item.id)
             |> is_nil()
    end
  end

  defp render(item, categories) do
    EditItemComponent
    |> render_component(item: item, categories: categories, myself: 1)
    |> Floki.parse_document!()
  end
end
