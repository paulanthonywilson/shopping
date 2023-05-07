defmodule ShoppingWeb.ChecklistLive.FormComponent do
  use ShoppingWeb, :live_component

  alias Shopping.Checklists

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage checklist records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="checklist-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Checklist</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{checklist: checklist} = assigns, socket) do
    changeset = Checklists.change_checklist(checklist)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"checklist" => checklist_params}, socket) do
    changeset =
      socket.assigns.checklist
      |> Checklists.change_checklist(checklist_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"checklist" => checklist_params}, socket) do
    save_checklist(socket, socket.assigns.action, checklist_params)
  end

  defp save_checklist(socket, :edit, checklist_params) do
    case Checklists.update_checklist(socket.assigns.checklist, checklist_params) do
      {:ok, checklist} ->
        notify_parent({:saved, checklist})

        {:noreply,
         socket
         |> put_flash(:info, "Checklist updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_checklist(socket, :new, checklist_params) do
    case Checklists.create_checklist(checklist_params) do
      {:ok, checklist} ->
        notify_parent({:saved, checklist})

        {:noreply,
         socket
         |> put_flash(:info, "Checklist created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
