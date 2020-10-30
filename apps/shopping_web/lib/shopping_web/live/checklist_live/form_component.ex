defmodule ShoppingWeb.ChecklistLive.FormComponent do
  @moduledoc """
  Geneerated component for adding or editing checklists (just the name really)
  """
  use ShoppingWeb, :live_component

  alias Shopping.Checklists

  @impl true
  def update(%{checklist: checklist} = assigns, socket) do
    changeset = Checklists.change_checklist(checklist)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"checklist" => checklist_params}, socket) do
    changeset =
      socket.assigns.checklist
      |> Checklists.change_checklist(checklist_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"checklist" => checklist_params}, socket) do
    save_checklist(socket, socket.assigns.action, checklist_params)
  end

  defp save_checklist(socket, :edit, checklist_params) do
    case Checklists.update_checklist(socket.assigns.checklist, checklist_params) do
      {:ok, _checklist} ->
        {:noreply,
         socket
         |> put_flash(:info, "Checklist updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_checklist(socket, :new, checklist_params) do
    case Checklists.create_checklist(checklist_params) do
      {:ok, _checklist} ->
        {:noreply,
         socket
         |> put_flash(:info, "Checklist created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end
end
