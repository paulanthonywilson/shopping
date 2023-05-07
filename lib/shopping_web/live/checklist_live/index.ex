defmodule ShoppingWeb.ChecklistLive.Index do
  use ShoppingWeb, :live_view

  alias Shopping.Checklists
  alias Shopping.Checklists.Checklist

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :checklists, Checklists.list_checklists())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Checklist")
    |> assign(:checklist, Checklists.get_checklist!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Checklist")
    |> assign(:checklist, %Checklist{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Checklists")
    |> assign(:checklist, nil)
  end

  @impl true
  def handle_info({ShoppingWeb.ChecklistLive.FormComponent, {:saved, checklist}}, socket) do
    {:noreply, stream_insert(socket, :checklists, checklist)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    checklist = Checklists.get_checklist!(id)
    {:ok, _} = Checklists.delete_checklist(checklist)

    {:noreply, stream_delete(socket, :checklists, checklist)}
  end
end
