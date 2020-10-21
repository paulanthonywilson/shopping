defmodule ShoppingWeb.ChecklistLive.Show do
  use ShoppingWeb, :live_view

  alias Shopping.Checklists

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    checklist = Checklists.get_checklist!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action, checklist))
     |> assign(:checklist, checklist)}
  end

  defp page_title(:show, %{name: name}), do: name
  defp page_title(:edit, %{name: name}), do: "Change #{name}"
end
