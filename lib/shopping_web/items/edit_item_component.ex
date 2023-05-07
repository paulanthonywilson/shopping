defmodule ShoppingWeb.Items.EditItemComponent do
  use ShoppingWeb, :live_component
  alias Shopping.Items
  import ShoppingWeb.CoreComponents

  attr :item, :map, required: true
  attr :categories, :list, required: true

  def render(%{categories: categories} = assigns) do
    options =
      for %{id: id, category_name: name, emoji: emoji} <- categories, do: {"#{emoji} #{name}", id}

    assigns = assign(assigns, options: options)

    ~H"""
    <div>
      <header class="text-center"><%= @item.name %></header>
      <form phx-change="change-category" phx-target={@myself}>
        <.input
          type="select"
          name="category"
          options={@options}
          value={@item.category.id}
          label="Category"
        />
      </form>
      <.button phx-click="delete" class="mt-3 bg-red-800" phx-target={@myself}>Delete</.button>
    </div>
    """
  end

  def handle_event("change-category", %{"category" => category_id}, socket) do
    %{assigns: %{item: item}} = socket
    {:ok, _} = Items.set_category(item, category_id)
    close_reply(socket)
  end

  def handle_event("delete", _, socket) do
    %{assigns: %{item: item}} = socket
    Items.delete_item(item)
    close_reply(socket)
  end

  defp close_reply(socket) do
    %{assigns: %{patch: patch}} = socket
    {:noreply, push_patch(socket, to: patch)}
  end
end
