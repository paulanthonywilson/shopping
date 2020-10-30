defmodule ShoppingWeb.DisplayItemComponent do
  @moduledoc """
  Display item emoji and name, with a link to edit the item's category
  """
  use ShoppingWeb, :live_component

  alias Shopping.Items.Item

  def render(assigns) do
    ~L"<%= content(@socket, @item) %>"
  end

  @doc """
  Convenience for displaying this component
  """
  @spec display_item(Phoenix.LiveView.Socket.t(), Item.t()) :: Phoenix.LiveView.Component.t()
  def display_item(socket, item) do
    live_component(socket, __MODULE__, item: item)
  end

  defp content(socket, item) do
    live_patch("#{item_emoji(item)} #{item.name}",
      to: Routes.checklist_show_path(socket, :edit_item_category, item.checklist_id, item)
    )
  end

  defp item_emoji(item) do
    item.category.emoji
  end
end
