defmodule ShoppingWeb.ChecklistLiveTest do
  use ShoppingWeb.ConnCase

  import Phoenix.LiveViewTest
  import Shopping.ChecklistsFixtures

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  defp create_checklist(_) do
    checklist = checklist_fixture()
    %{checklist: checklist}
  end

  describe "Index" do
    setup [:create_checklist]

    test "lists all checklists", %{conn: conn, checklist: checklist} do
      {:ok, _index_live, html} = live(conn, ~p"/checklists")

      assert html =~ "Listing Checklists"
      assert html =~ checklist.name
    end

    test "saves new checklist", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/checklists")

      assert index_live |> element("a", "New Checklist") |> render_click() =~
               "New Checklist"

      assert_patch(index_live, ~p"/checklists/new")

      assert index_live
             |> form("#checklist-form", checklist: @invalid_attrs)
             |> render_change()
             |> Floki.parse_document!()
             |> Floki.text() =~ "can't be blank"

      assert index_live
             |> form("#checklist-form", checklist: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/checklists")

      html = render(index_live)
      assert html =~ "Checklist created successfully"
      assert html =~ "some name"
    end

    test "updates checklist in listing", %{conn: conn, checklist: checklist} do
      {:ok, index_live, _html} = live(conn, ~p"/checklists")

      assert index_live |> element("#checklists-#{checklist.id} a", "Edit") |> render_click() =~
               "Edit Checklist"

      assert_patch(index_live, ~p"/checklists/#{checklist}/edit")

      assert index_live
             |> form("#checklist-form", checklist: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#checklist-form", checklist: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/checklists")

      html = render(index_live)
      assert html =~ "Checklist updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes checklist in listing", %{conn: conn, checklist: checklist} do
      {:ok, index_live, _html} = live(conn, ~p"/checklists")

      assert index_live |> element("#checklists-#{checklist.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#checklists-#{checklist.id}")
    end
  end

  describe "Show" do
    setup [:create_checklist]

    test "displays checklist", %{conn: conn, checklist: checklist} do
      {:ok, show_live, html} = live(conn, ~p"/checklists/#{checklist}")

      assert html =~ checklist.name

      show_live
      |> Map.get(:pid)
      |> :sys.get_state()
    end
  end
end
