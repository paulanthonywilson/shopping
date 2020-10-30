defmodule ShoppingWeb.AddItemsComponent do
  @moduledoc """
  Form to embed in show, adds item.
  """
  use ShoppingWeb, :live_component

  alias Shopping.Items

  def update(assigns, socket) do
    checklist = Map.fetch!(assigns, :checklist)

    assigns =
      assigns
      |> Map.put(:changeset, Items.create_changeset(checklist))

    {:ok, assign(socket, assigns)}
  end

  def render(assigns) do
    ~L"""
    <div class="add-item-form">
        <button class="button button-outline clear" phx-click="add-item-clear"
               phs_disable_with="...", phx-target="<%= @myself %>"">X</button>
       <%= f = form_for @changeset, "#", phx_submit: "insert", phx_change: "text-change", phx_target: @myself %>

       <div class="field add-item"  >
       <%= text_input f, :name,
                placeholder: "Name",
                autocomplete: "off",
                phx_debounce: "300",
                value: @name %>
       <%= error_tag f, :name %>
       </div>

       <%= submit "add", phx_disable_with: "Saving..." %>
       </form>
    </div>
    """
  end

  def handle_event("add-item-clear", _, socket) do
    {:noreply, name_field_change(socket, "")}
  end

  def handle_event("text-change", %{"item" => %{"name" => name}}, socket) do
    {:noreply, name_field_change(socket, name)}
  end

  def handle_event("insert", %{"item" => item}, socket) do
    %{checklist: checklist} = socket.assigns

    socket =
      case Items.create_item(checklist, item) do
        {:ok, _item} ->
          socket
          |> assign(socket, changeset: Items.create_changeset(checklist))
          |> name_field_change("")

        {:error, changeset} ->
          assign(socket, changeset: changeset)
      end

    {:noreply, socket}
  end

  defp name_field_change(socket, value) do
    send(self(), {:filter_text, value})
    assign(socket, name: value)
  end
end
