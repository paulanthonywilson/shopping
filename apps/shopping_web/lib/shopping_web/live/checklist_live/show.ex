defmodule ShoppingWeb.ChecklistLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.{Checklists, Items}
  alias ShoppingWeb.{AddItemsComponent, ListItemsToGetComponent, ListItemsGotComponent}

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, filter: "")}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
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
  def handle_event("change-importance", %{"id" => id} = params, socket) do
    value = params["value"] || false
    Items.change_importance_to(id, value)
    {:noreply, socket}
  end

  def handle_event("change-got", %{"id" => id} = params, socket) do
    value = params["value"] || false
    Items.change_got_to(id, value)
    {:noreply, socket}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    Items.delete_item(id)
    {:noreply, socket}
  end

  @impl true
  def handle_info({"item-change-importance", item}, socket) do
    to_get =
      socket.assigns
      |> Map.get(:to_get)
      |> Items.update_in_list_of_items(item)

    {:noreply, assign(socket, to_get: to_get)}
  end

  def handle_info({"item-change-got", %{got?: true} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: [item | got],
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  def handle_info({"item-change-got", %{got?: false} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.sort_in_order_of_importance([item | to_get]),
       filter: ""
     )}
  end

  def handle_info({"item-created", %{got?: true} = item}, socket) do
    %{got: got} = socket.assigns

    {:noreply, assign(socket, got: [item | got])}
  end

  def handle_info({"item-created", %{got?: false} = item}, socket) do
    %{to_get: to_get} = socket.assigns
    {:noreply, assign(socket, to_get: Items.sort_in_order_of_importance([item | to_get]))}
  end

  def handle_info({"item-deleted", item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  def handle_info({:filter_text, text}, socket) do
    {:noreply, assign(socket, filter: text)}
  end

  def handle_info(_, socket) do
    {:noreply, socket}
  end

  defp page_title(:show, %{name: name}), do: name
  defp page_title(:edit, %{name: name}), do: "Change #{name}"
end
