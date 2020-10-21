defmodule ShoppingWeb.ChecklistLiveTest do
  use ShoppingWeb.ConnCase

  import Phoenix.LiveViewTest

  alias Shopping.Checklists

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp fixture(:checklist) do
    {:ok, checklist} = Checklists.create_checklist(@create_attrs)
    checklist
  end

  defp create_checklist(_) do
    checklist = fixture(:checklist)
    %{checklist: checklist}
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
             |> render_change() =~ "can&apos;t be blank"

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
      {:ok, _show_live, html} = live(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert html =~ checklist.name
    end

    test "updates checklist within modal", %{conn: conn, checklist: checklist} do
      {:ok, show_live, _html} = live(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert show_live |> element("a", checklist.name) |> render_click() =~
               "Change #{checklist.name}"

      assert_patch(show_live, Routes.checklist_show_path(conn, :edit, checklist))

      assert show_live
             |> form("#checklist-form", checklist: @invalid_attrs)
             |> render_change() =~ "can&apos;t be blank"

      {:ok, _, html} =
        show_live
        |> form("#checklist-form", checklist: @update_attrs)
        |> render_submit()
        |> follow_redirect(conn, Routes.checklist_show_path(conn, :show, checklist))

      assert html =~ "Checklist updated successfully"
      assert html =~ "some updated name"
    end
  end
end
