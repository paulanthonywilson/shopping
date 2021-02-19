defmodule ShoppingWeb.ChecklistLiveTest do
  use ShoppingWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shopping.{Checklists, Items}

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:checklist) do
    {:ok, checklist} = Checklists.create_checklist(@create_attrs)
    checklist
  end

  defp fixture(:items, checklist) do
    for i <- 1..10 do
      case Items.create_item(checklist, %{name: "Item #{i}", got?: i > 6, important?: i < 3}) do
        {:ok, item} -> item
      end
    end
  end

  defp create_checklist(_) do
    checklist = fixture(:checklist)
    items = fixture(:items, checklist)
    %{checklist: checklist, items: items}
  end

  describe "Index" do
    setup [:create_checklist]

    test "lists all checklists", %{conn: conn, checklist: checklist} do
      {:ok, _index_live, html} = live(conn, Routes.checklist_index_path(conn, :index))

      assert html =~ checklist.name
    end

    test "saves new checklist", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, Routes.checklist_index_path(conn, :index))

      assert index_live |> element("a", "New Checklist") |> render_click() =~
               "New Checklist"

      assert_patch(index_live, Routes.checklist_index_path(conn, :new))

      assert index_live
             |> form("#checklist-form", checklist: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, _, html} =
        index_live
        |> form("#checklist-form", checklist: @create_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.checklist_index_path(conn, :index))

      assert html =~ "Checklist created successfully"
      assert html =~ "some name"
    end
  end

  describe "Show" do
    setup [:create_checklist]

    test "displays checklist", %{conn: conn, checklist: checklist} do
      {:ok, show_live, html} = live(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert html =~ checklist.name
      wait_for_items(show_live)
    end

    test "updates checklist within modal", %{conn: conn, checklist: checklist} do
      {:ok, show_live, _html} = live(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert show_live |> element("a", checklist.name) |> render_click() =~
               "Change #{checklist.name}"

      assert_patch(show_live, Routes.checklist_show_path(conn, :edit, checklist))

      assert show_live
             |> form("#checklist-form", checklist: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      {:ok, new_live, html} =
        show_live
        |> form("#checklist-form", checklist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert html =~ "Checklist updated successfully"
      assert html =~ "some updated name"
      wait_for_items(new_live)
    end

    test "handles item importance change to unimportant", %{
      conn: conn,
      checklist: checklist,
      items: [item | _]
    } do
      {:ok, live_view, _html} = live(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert Items.get_item!(item.id).important?
      render_hook(live_view, "change-importance", %{id: to_string(item.id)})

      refute Items.get_item!(item.id).important?
      wait_for_items(live_view)
    end

    defp wait_for_items(%{pid: pid}) do
      :sys.get_status(pid)
    end
  end
end
