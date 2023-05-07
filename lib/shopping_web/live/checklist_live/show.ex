defmodule ShoppingWeb.ChecklistLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.{Categories, Checklists, Items}
  import ShoppingWeb.Items.ItemsComponents

  @five_minutes 5 * 60 * 1_000

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, filter: "", categories: Categories.list_all_categories())}
  end

  @impl true
  def handle_params(%{"item_id" => item_id} = params, _, socket) do
    socket = assign(socket, :item, Items.get_item!(item_id))
    assign_checklist(params, socket)
  end

  def handle_params(params, _, socket) do
    assign_checklist(params, socket)
  end

  defp assign_checklist(%{"id" => id}, socket) do
    send(self(), :assign_items)
    checklist = Checklists.get_checklist!(id)
    Items.subscribe(checklist)

    socket =
      socket
      |> assign(:page_title, page_title(socket.assigns.live_action, checklist))
      |> assign(:checklist, checklist)
      |> assign(:to_get, [])
      |> assign(:filtered, [])
      |> assign(:got, [])
      |> assign(:add_item_errors, [])

    {:noreply, socket}
  end

  defp page_title(:edit, %{name: name}), do: "Change #{name}"
  defp page_title(_, %{name: name}), do: name

  @impl true
  def handle_info(:assign_items, socket) do
    Process.send_after(self(), :assign_items, @five_minutes)
    %{checklist: checklist} = socket.assigns
    items = Items.list_by_got(checklist)
    {:noreply, assign(socket, got: items.got, to_get: items.to_get)}
  end

  def handle_info({"item-changed-got", %{got?: true} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.add_to_list(got, item),
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  def handle_info({"item-changed-got", %{got?: false} = item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.add_to_list(to_get, item),
       filter: ""
     )}
  end

  def handle_info({"item-changed-importance", item}, socket) do
    to_get =
      socket.assigns
      |> Map.get(:to_get)
      |> Items.update_in_list_of_items(item)

    {:noreply, assign(socket, to_get: to_get)}
  end

  def handle_info({"item-created", %{got?: true} = item}, socket) do
    %{got: got} = socket.assigns

    {:noreply, assign(socket, got: Items.add_to_list(got, item))}
  end

  def handle_info({"item-created", %{got?: false} = item}, socket) do
    %{to_get: to_get} = socket.assigns
    {:noreply, assign(socket, to_get: Items.add_to_list(to_get, item))}
  end

  def handle_info({"item-changed-category", %{got?: false} = item}, socket) do
    to_get =
      socket.assigns
      |> Map.get(:to_get)
      |> Items.update_in_list_of_items(item)

    {:noreply, assign(socket, to_get: to_get)}
  end

  def handle_info({"item-deleted", item}, socket) do
    %{got: got, to_get: to_get} = socket.assigns

    {:noreply,
     assign(socket,
       got: Items.remove_item_from_list(got, item),
       to_get: Items.remove_item_from_list(to_get, item)
     )}
  end

  def handle_info({"item-changed-category", %{got?: true} = item}, socket) do
    %{got: got} = socket.assigns

    {:noreply, assign(socket, got: Items.update_in_list_of_items(got, item))}
  end

  @impl true
  def handle_event("change-got", %{"id" => item_id} = params, socket) do
    value =
      case params["value"] do
        "true" -> true
        _ -> false
      end

    Items.change_got_to(item_id, value)
    {:noreply, socket}
  end

  def handle_event("change-importance", %{"id" => id} = params, socket) do
    value = params["value"] || false
    Items.change_importance_to(id, value)
    {:noreply, socket}
  end

  def handle_event("text-change", %{"filter" => filter}, socket) do
    {:noreply, assign(socket, filter: filter)}
  end

  def handle_event("clear-filter", _, socket) do
    {:noreply, assign(socket, filter: "")}
  end

  def handle_event("add-item", %{"filter" => name}, socket) do
    %{assigns: %{checklist: checklist}} = socket

    socket =
      case Items.create_item(checklist, %{name: name}) do
        {:error, %{errors: errs}} ->
          errors = for {:name, {msg, _}} <- errs, do: msg
          assign(socket, :add_item_errors, errors)

        {:ok, _item} ->
          put_flash(socket, :info, "#{name} added")
      end

    {:noreply, socket}
  end
end
