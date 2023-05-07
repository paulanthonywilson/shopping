defmodule ShoppingWeb.Items.ItemsComponentsTest do
  use ShoppingWeb.ConnCase
  import Phoenix.LiveViewTest
  import LightItemsFixtures
  alias ShoppingWeb.Items.ItemsComponents

  describe "got items" do
    test "displays items" do
      got =
        some_test_items(2, true) ++
          [test_item(3, "Item 3", true, emoji: "🤡", last_got: ~U[2020-03-16 21:00:00Z])]

      assert {:ok, html} =
               render_component(&ItemsComponents.got_table/1, got: got, filter: "")
               |> Floki.parse_document()

      text = Floki.text(html)

      assert text =~ "😍 Item 1"
      assert text =~ "🤡 Item 3"
      assert text =~ ~r/\d+ days/

      assert [] != Floki.find(html, "tbody#got")

      for i <- 1..3 do
        assert [] !=
                 Floki.find(
                   html,
                   "input[type='checkbox'][checked='checked'][phx-click='change-got'][phx-value-id='#{i}']"
                 ),
               "Finding got checkbox for #{i}"
      end

      Floki.find(html, "td input[name='got']")
    end

    test "filter items" do
      got = [
        test_item(1, "Bob", true),
        test_item(2, "Bovril", true),
        test_item(3, "Botox", true),
        test_item(4, "Fish", true)
      ]

      html =
        render_component(&ItemsComponents.got_table/1, got: got, filter: "bo")
        |> Floki.parse_document!()

      assert 3 == html |> Floki.find("input[phx-click='change-got']") |> length()

      html =
        render_component(&ItemsComponents.got_table/1, got: got, filter: "BOT")
        |> Floki.parse_document!()

      assert 1 == html |> Floki.find("input[phx-click='change-got']") |> length()

      html =
        render_component(&ItemsComponents.got_table/1, got: got, filter: "botty")
        |> Floki.parse_document!()

      assert [] == html |> Floki.find("input[phx-click='change-got']")
    end
  end

  describe "to get items table" do
    setup do
      to_get = [
        test_item(1, "Item 1", false),
        test_item(2, "Item 2", false),
        test_item(3, "Item 3", false, emoji: "🤡", important?: true)
      ]

      assert {:ok, html} =
               render_component(&ItemsComponents.to_get_table/1,
                 to_get: to_get,
                 checklist: %{name: "teh shoppinigz"}
               )
               |> Floki.parse_document()

      {:ok, html: html}
    end

    test "displays item names with emoji", %{html: html} do
      text = Floki.text(html)
      assert text =~ "😍 Item 1"
      assert text =~ "😍 Item 2"
      assert text =~ "🤡 Item 3"
    end

    test "displays change-got checkbox", %{html: html} do
      for i <- 1..3 do
        assert [{"input", box_attrs, []}] =
                 Floki.find(
                   html,
                   "input[type='checkbox'][phx-click='change-got'][phx-value-id='#{i}']"
                 ),
               "Finding to_got checkbox for #{i}"

        refute List.keyfind(box_attrs, "checked", 0)
      end
    end

    test "displays change-importance checkbox is unchecked when not important", %{html: html} do
      assert [{"input", box_attrs, []}] =
               Floki.find(
                 html,
                 "input[type='checkbox'][phx-click='change-importance'][phx-value-id='1']"
               )

      refute List.keyfind(box_attrs, "checked", 0)
    end

    test "displays change-importance checkbox is checked when not important", %{html: html} do
      assert [{"input", box_attrs, []}] =
               Floki.find(
                 html,
                 "input[type='checkbox'][phx-click='change-importance'][phx-value-id='3']"
               )

      assert List.keyfind(box_attrs, "checked", 0)
    end

    test "styles important category differently", %{html: html} do
      assert [{"tr", _, children}] = Floki.find(html, "tr.bg-violet-100")

      assert [{"input", attrs, []}] =
               Floki.find(children, "input[type='checkbox'][phx-click='change-got']")

      assert {_, "3"} = List.keyfind(attrs, "phx-value-id", 0)
    end
  end
end
