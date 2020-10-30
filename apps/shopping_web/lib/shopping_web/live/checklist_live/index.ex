defmodule ShoppingWeb.ChecklistLive.Index do
  @moduledoc """
  Lists checklists

  """
  use ShoppingWeb, :live_view

  alias Shopping.Checklists
  alias Shopping.Checklists.Checklist

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :checklists, list_checklists())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Change name")
    |> assign(:checklist, Checklists.get_checklist!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Checklist")
    |> assign(:checklist, %Checklist{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Checklists")
    |> assign(:checklist, nil)
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    checklist = Checklists.get_checklist!(id)
    {:ok, _} = Checklists.delete_checklist(checklist)

    {:noreply, assign(socket, :checklists, list_checklists())}
  end

  defp list_checklists do
    Checklists.list_checklists()
  end
end
