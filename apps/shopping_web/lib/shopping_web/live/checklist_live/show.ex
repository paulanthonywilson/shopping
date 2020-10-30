defmodule ShoppingWeb.ChecklistLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.{Categories, Checklists, Items}
  alias ShoppingWeb.{AddItemsComponent, ListItemsToGetComponent, ListItemsGotComponent}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, filter: "", categories: Categories.list_all_categories())}
  end

  @impl true

  def handle_params(%{"item_id" => item_id} = params, _, socket) do
    item = Items.get_item!(item_id)
    assign_checklist_and_items(params, assign(socket, item: item))
  end

  def handle_params(params, _, socket) do
    assign_checklist_and_items(params, socket)
  end

  defp assign_checklist_and_items(%{"id" => id}, socket) do
    checklist = Checklists.get_checklist!(id)
    Items.subscribe(checklist)
    items = Items.list_by_got(checklist)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, checklist))
     |> assign(:checklist, checklist)
     |> assign(got: items.got)
     |> assign(to_get: items.to_get)}
  end

  @impl true
  def handle_event(event, params, socket) do
    do_handle_event(event, params, clear_flash(socket))
  end

  defp do_handle_event("change-importance", %{"id" => id} = params, socket) do
    value = params["value"] || false
    Items.change_importance_to(id, value)
    {:noreply, socket}
  end

  defp do_handle_event("change-got", %{"id" => id} = params, socket) do
    value = params["value"] || false
    Items.change_got_to(id, value)
    {:noreply, socket}
  end

  defp do_handle_event("delete", %{"id" => id}, socket) do
    Items.delete_item(id)
    {:noreply, socket}
  end

  defp do_handle_event("update-item-category", %{"item-category-id" => category_id}, socket) do
    %{item: item, checklist: checklist} = socket.assigns
    {:ok, item} = Items.set_category(item, category_id)

    {:noreply,
     socket
     |> put_flash(:info, "#{item.name} category updated to #{item.category.emoji}")
     |> push_redirect(to: Routes.checklist_show_path(socket, :show, checklist))}
  end

  @impl true
  def handle_info(event, socket) do
    do_handle_info(event, clear_flash(socket))
  end

  defp do_handle_info({"item-changed-importance", item}, socket) do
    to_get =
      socket.assigns
      |> Map.get(:to_get)
      |> Items.update_in_list_of_items(item)

    {:noreply, assign(socket, to_get: to_get)}
  end

  defp do_handle_info({"item-changed-category", %{got?: false} = item}, socket) do
    to_get =
      socket.assigns
      |> Map.get(:to_get)
      |> Items.update_in_list_of_items(item)

    {:noreply, assign(socket, to_get: to_get)}
  end

  defp do_handle_info({"item-changed-category", %{got?: true} = item}, socket) do
    %{got: got} = socket.assigns

    {:noreply, assign(socket, got: Items.update_in_list_of_items(got, item))}
  end

  defp do_handle_info({"item-changed-got", %{got?: true} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: [item | got],
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  defp do_handle_info({"item-changed-got", %{got?: false} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.sort_for_display([item | to_get]),
       filter: ""
     )}
  end

  defp do_handle_info({"item-created", %{got?: true} = item}, socket) do
    %{got: got} = socket.assigns

    {:noreply, assign(socket, got: [item | got])}
  end

  defp do_handle_info({"item-created", %{got?: false} = item}, socket) do
    %{to_get: to_get} = socket.assigns
    {:noreply, assign(socket, to_get: Items.sort_for_display([item | to_get]))}
  end

  defp do_handle_info({"item-deleted", item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  defp do_handle_info({:filter_text, text}, socket) do
    {:noreply, assign(socket, filter: text)}
  end

  defp do_handle_info(_, socket) do
    {:noreply, socket}
  end

  defp page_title(:edit, %{name: name}), do: "Change #{name}"
  defp page_title(_, %{name: name}), do: name
end
