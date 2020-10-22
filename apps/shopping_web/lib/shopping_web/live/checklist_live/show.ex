defmodule ShoppingWeb.ChecklistLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.{Checklists, Items}
  alias ShoppingWeb.ListItemsToGetComponent

  @impl true
  def mount(_params, _session, socket) do
    Items.subscribe()
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    checklist = Checklists.get_checklist!(id)
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

  def handle_info({"item-change-importance", item}, socket) do
    {:noreply, socket}
  end

  defp page_title(:show, %{name: name}), do: name
  defp page_title(:edit, %{name: name}), do: "Change #{name}"
end
